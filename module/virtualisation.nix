{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.vm;
  nodeConfig = config.cluster.nodes."${config.cluster.nodeName}";
  networkConfig = config.cluster.network.edges.${config.cluster.nodeName}.config;
in
with builtins;
{
  options = with lib; {
    vm.guest-reserved = mkOption {
      type = types.int;
      default = 400;
    };
    vm.host-reserved = mkOption {
      type = types.int;
      default = 800;
    };
    vm.guest-reserved-percent = mkOption {
      type = types.float;
      default = 0.0;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf nodeConfig.virtualisation.enable {
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
      boot.kernelParams = [
        "intel_iommu=on"
        "amd_iommu=on"
        "elevator=deadline"
      ];
      boot.extraModprobeConfig = ''
        softdep nouveau       pre: vfio-pci
        softdep snd_hda_intel pre: vfio-pci
        softdep xhci_pci      pre: vfio-pci

        options vfio-pci ids=8086:a7a0
      '';
      virtualisation = {
        lxd = {
          package = pkgs.lxd;
          recommendedSysctlSettings = true;
        };
        lxc.lxcfs.enable = false;
        libvirtd = {
          enable = true;
          package = pkgs.libvirt.overrideAttrs (oldAttrs: {
            postInstall =
              oldAttrs.postInstall
              + ''
                sed -i 's|name>|name>\n  <dns enable="no"/>|' $out/var/lib/libvirt/qemu/networks/default.xml
              '';
          });
          # qemu.ovmf.enable = true;
          # qemu.ovmf.packages = [ pkgs.OVMFFull ];
          # qemu.swtpm.enable = true;

          parallelShutdown = 8;
          onBoot = "ignore";
          onShutdown = "shutdown";
          extraConfig = ''
            listen_tls = 0
            listen_tcp = 1
            tcp_port = "16509" 
            listen_addr = "0.0.0.0"
            auth_tcp = "none"
          '';
          qemu.vhostUserPackages = [ pkgs.virtiofsd ];
        };
        kvmgt.enable = true;
        waydroid.enable = false;
        # spiceUSBRedirection.enable = true;
        podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };
      hardware.ksm.enable = true;
      systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 wangzi kvm -" ];
      systemd.services.balloond = {
        enable = true;
        wantedBy = [ "libvirtd.service" ];
        environment = {
          RUST_LOG = "info";
        };
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "5s";
          ExecStart = "${pkgs.balloond}/bin/balloond -r ${toString cfg.guest-reserved} -R ${toString cfg.host-reserved} -p ${toString cfg.guest-reserved-percent} -d 1 -h 4";
        };
      };
      environment.etc."qemu/vhost-user".source = "${pkgs.qemu}/share/qemu/vhost-user";
      programs.virt-manager.enable = true;
      environment.etc."libvirt/libvirtd.conf".source = "${pkgs.qemu}/share/qemu/vhost-user";
      environment.systemPackages = with pkgs; [
        looking-glass-client
        virtiofsd
        podman-compose
        qemu
        virt-manager
        virt-viewer
        rdesktop
      ];
      systemd.services.libvirtd = with pkgs; {
        path = [
          virtiofsd
          swtpm-tpm2
          virglrenderer
        ];
        environment.LD_LIBRARY_PATH = "${virglrenderer}/lib";
        unitConfig = {
          After = [ "kea-dhcp4-server.service" ];
        };
      };

      virtualisation.libvirt.swtpm.enable = true;
      virtualisation.libvirt.connections."qemu:///session" = {
        networks = [
          {
            definition = lib.network.getXML {
              name = "default";
              uuid = "1af25fd8-af0b-11ef-8569-efcee4ef42f5";
              dns.enable = "no";
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
              bridge = {
                name = "virbr0";
              };
              mac = {
                address = "52:54:00:02:77:4b";
              };
              ip = {
                address = "192.168.32.1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "192.168.32.2";
                    end = "192.168.32.254";
                  };
                };
              };
            };
            active = true;
          }
        ];
        pools = lib.pool.getXML {
          name = "home";
          uuid = "f0e397de-af0a-11ef-ba8a-37c366f1c2cf";
          type = "dir";
          target = {
            path = "/home/wangzi/vm/";
          };
        };
      };

      networking.firewall.trustedInterfaces = [ "virbr0" ];
      networking.dhcpcd.denyInterfaces = [ "eno1" ];

      services.samba-wsdd.enable = true;
      services.samba = {
        enable = true;
        securityType = "user";
        extraConfig = ''
          workgroup = WORKGROUP
          server string = 192.168.122.1
          netbios name = ${config.networking.hostName}
          #use sendfile = yes
          #max protocol = smb2
          # note: localhost is the ipv6 localhost ::1
          hosts allow = 192.168.122. 127.0.0.1 localhost
          hosts deny = 0.0.0.0/0
          guest account = wangzi
          map to guest = bad user
          follow symlinks = yes
          wide links = yes
          allow insecure wide links = yes
        '';
        shares = {
          wangzi-home = {
            path = "/home/wangzi";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "follow symlinks" = "yes";
            "wide links" = "yes";
            "acl allow execute always" = "yes";
          };
          nix-store = {
            path = "/nix/store";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "follow symlinks" = "yes";
            "wide links" = "yes";
          };
        };
      };
    })
    (lib.mkIf nodeConfig.NextCloudServer.enable {
      virtualisation.oci-containers.containers.virtlyst = {
        image = "dantti/virtlyst";
        volumes = [
          "virtlyst:/root"
          "/root/.ssh:/root/.ssh"
        ];
        ports = [ "9090:80" ];
      };
      services.caddy = lib.optionalAttrs nodeConfig.NextCloudServer.enable {
        enable = true;
        virtualHosts = {
          "https://${builtins.toString networkConfig.publicIp}:9093" = {
            extraConfig = ''
              reverse_proxy http://localhost:9090
            '';
          };
        };
      };
      networking.firewall.allowedTCPPorts = [ 9093 ];
    })
  ];
}
