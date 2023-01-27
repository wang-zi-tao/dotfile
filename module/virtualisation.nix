{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.cluster.nodeConfig.virtualisation.enable {
    boot.kernelParams = [
      "elevator=deadline"
    ];
    virtualisation = {
      lxd = {
        enable = false;
        package = pkgs.lxd;
        recommendedSysctlSettings = true;
      };
      lxc.lxcfs.enable = false;
      libvirtd = {
        enable = true;
        qemu.ovmf.enable = true;
        qemu.ovmf.packages = [ pkgs.OVMFFull ];
        qemu.swtpm.enable = true;
      };
      kvmgt.enable = true;
      waydroid.enable = false;
      podman = {
        enable = true;
        defaultNetwork.dnsname.enable = true;
      };
    };
    systemd.services.balloond = {
      enable = true;
      wantedBy = [ "libvirtd.service" ];
      environment = { RUST_LOG = "info"; };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = "${pkgs.balloond}/bin/balloond -r 500 -p 0.5 -d 2 -h 16";
      };
    };
    environment.etc."qemu/vhost-user".source = "${pkgs.qemu_full}/share/qemu/vhost-user";
    environment.systemPackages = with pkgs; [ qemu virt-manager virt-viewer rdesktop ];
    systemd.services.libvirtd = with pkgs; {
      path = [ virtiofsd swtpm-tpm2 virglrenderer ];
      environment.LD_LIBRARY_PATH = "${virglrenderer}/lib";
    };
    networking.firewall.trustedInterfaces = [ "virbr0" ];
  };
}
