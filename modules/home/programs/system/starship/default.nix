# Starship shell prompt module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.starship;
in
{
  options.${namespace}.programs.system.starship = mkSystemToolOptions "Starship" // {
    # Starship-specific options
    preset = mkEnumOpt [ "default" "minimal" "nerd-font" "bracketed-segments" "plain-text" ] "default"
      "Starship preset configuration";

    settings = mkAttrsOpt {
      add_newline = true;
      command_timeout = 10000;
    } "Starship configuration settings";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Starship" cfg;

    programs.starship = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.starship;

      enableZshIntegration = true;

      settings = {
        # Global settings
        add_newline = cfg.settings.add_newline or true;
        command_timeout = cfg.settings.command_timeout or 10000;

        # Cloud configurations
        aws = {
          disabled = true;
        };

        gcloud = {
          disabled = true;
        };

        # Kubernetes
        kubernetes = {
          disabled = false;
          detect_folders = [".helm"];
          detect_files = [
            "docker-compose.yml"
            "docker-compose.yaml"
            "Dockerfile"
            "helmfile.yaml"
          ];
        };
      } // cfg.settings // cfg.extraConfig;
    };
  };
}
