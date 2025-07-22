# User configuration module with namespace support
{ config, lib, pkgs, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.user;

  home-directory = if cfg.name == null then null else
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${cfg.name}" else "/home/${cfg.name}";
in
{
  options.${namespace}.user = {
    enable = mkBoolOpt false "Enable user account configuration";

    email = mkStrOpt "killtw@gmail.com" "The email of the user";

    fullName = mkStrOpt "Karl Li" "The full name of the user";

    home = mkOption {
      type = types.nullOr types.str;
      default = home-directory;
      description = "The user's home directory";
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = "killtw";
      description = "The user account name";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "${namespace}.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "${namespace}.user.home must be set";
      }
      {
        assertion = cfg.email != "";
        message = "${namespace}.user.email cannot be empty";
      }
      {
        assertion = cfg.fullName != "";
        message = "${namespace}.user.fullName cannot be empty";
      }
    ];

    home = {
      homeDirectory = mkDefault cfg.home;
      username = mkDefault cfg.name;
    };

    programs.home-manager.enable = true;

    # Add deprecation warning for old configuration
    warnings = optional (config.programs.user-config.enable or false)
      "programs.user-config is deprecated. Use ${namespace}.user instead.";
  };
}
