{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.user-config;

  home-directory = if cfg.name == null then null else
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${cfg.name}" else "/home/${cfg.name}";
in
{
  options.programs.user-config = {
    enable = mkEnableOption "user account configuration";
    email = mkOption {
      type = types.str;
      default = "killtw@gmail.com";
      description = "The email of the user.";
    };
    fullName = mkOption {
      type = types.str;
      default = "Karl Li";
      description = "The full name of the user.";
    };
    home = mkOption {
      type = types.nullOr types.str;
      default = home-directory;
      description = "The user's home directory.";
    };
    name = mkOption {
      type = types.nullOr types.str;
      default = "killtw";
      description = "The user account.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "programs.user-config.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "programs.user-config.home must be set";
      }
    ];

    home = {
      homeDirectory = mkDefault cfg.home;
      username = mkDefault cfg.name;
    };

    programs.home-manager.enable = true;
  };
}
