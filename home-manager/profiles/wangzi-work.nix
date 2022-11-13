{ nixpkgs, home-manager, pkgs, ... }:
let lib = pkgs.lib; in
{
  pkgs = pkgs;
  system = pkgs.system;
  username = "wangzi";
  homeDirectory = "/home/wangzi";
  configuration = {
    imports = [
      ../application/application.nix
      ../develop/cpp.nix
      ../terminal/terminal.nix
      ../develop/develop.nix
    ];
    neovim.full = true;
    programs.git.userName = lib.mkForce "wangzitao";
    programs.git.userEmail = lib.mkForce "wangzitao@kingsoft.com";
  };
}
