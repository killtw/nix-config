{ config, lib, pkgs, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = {
    name = mkStrOpt "killtw" "The user account.";
    email = mkStrOpt "killtw@gmail.com" "The email of the user.";
    fullName = mkStrOpt "Karl Li" "The full name of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
    hostname = mkStrOpt "mini" "The hostname for this system.";
  };

  config = {
    networking.hostName = cfg.hostname;
    networking.computerName = cfg.hostname;
    system.defaults.smb.NetBIOSName = cfg.hostname;

    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
      home = "/Users/${cfg.name}";
      description = cfg.fullName;
      shell = pkgs.zsh;
    };

    nix.settings.trusted-users = ["@admin" cfg.name];
  };
}
