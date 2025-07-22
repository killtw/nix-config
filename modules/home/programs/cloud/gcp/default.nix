# Google Cloud Platform CLI module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.gcp;
in
{
  options.${namespace}.programs.cloud.gcp = mkCloudToolOptions "Google Cloud CLI" // {
    # GCP-specific options
    enableCompletion = mkBoolOpt true "Enable shell completion";

    project = mkStrOptNull "Default GCP project ID";

    enableBetaCommands = mkBoolOpt false "Enable beta commands";
    enableAlphaCommands = mkBoolOpt false "Enable alpha commands";

    configurations = mkAttrsOpt {} "GCP configurations";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for Google Cloud CLI";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Google Cloud CLI" cfg;

    home.packages = [
      (mkPackageWithFallback cfg pkgs.google-cloud-sdk)
    ];

    # Environment variables
    home.sessionVariables = optionalAttrs (cfg.project != null) {
      GOOGLE_CLOUD_PROJECT = cfg.project;
      GCLOUD_PROJECT = cfg.project;
    };
  };
}
