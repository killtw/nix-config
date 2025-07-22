# AWS CLI module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.awscli;
in
{
  options.${namespace}.programs.cloud.awscli = mkCloudToolOptions "AWS CLI" // {
    # AWS CLI-specific options
    enableCompletion = mkBoolOpt true "Enable shell completion";

    defaultOutput = mkEnumOpt [ "json" "yaml" "yaml-stream" "text" "table" ] "json"
      "Default output format";

    enablePager = mkBoolOpt true "Enable pager for output";

    profiles = mkAttrsOpt {} "AWS CLI profiles configuration";

    credentials = mkAttrsOpt {} "AWS credentials configuration";

    enableS3Transfer = mkBoolOpt true "Enable S3 transfer acceleration";

    maxBandwidth = mkStrOptNull "Maximum bandwidth for transfers";

    cliHistoryEnabled = mkBoolOpt true "Enable CLI history";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for AWS CLI";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "AWS CLI" cfg;

    home.packages = [
      (mkPackageWithFallback cfg pkgs.awscli2)
      # JSON processing
      pkgs.jq
    ];

    # AWS CLI configuration
    home.file.".aws/config" = mkIf (cfg.profiles != {} || cfg.region != null) {
      text = ''
        [default]
        ${optionalString (cfg.region != null) "region = ${cfg.region}"}
        ${optionalString (cfg.profile != null) "profile = ${cfg.profile}"}
        output = ${cfg.defaultOutput}
        ${optionalString cfg.enablePager "cli_pager = less"}
        ${optionalString (!cfg.enablePager) "cli_pager = "}
        ${optionalString cfg.cliHistoryEnabled "cli_history = enabled"}
        ${optionalString cfg.enableS3Transfer "s3 =\n    use_accelerate_endpoint = true"}
        ${optionalString (cfg.maxBandwidth != null) "    max_bandwidth = ${cfg.maxBandwidth}"}

        ${concatStringsSep "\n" (mapAttrsToList (name: profile: ''
          [profile ${name}]
          ${concatStringsSep "\n" (mapAttrsToList (key: value: "${key} = ${toString value}") profile)}
        '') cfg.profiles)}
      '';
    };

    # AWS credentials (if specified)
    home.file.".aws/credentials" = mkIf (cfg.credentials != {}) {
      text = concatStringsSep "\n" (mapAttrsToList (name: creds: ''
        [${name}]
        ${concatStringsSep "\n" (mapAttrsToList (key: value: "${key} = ${toString value}") creds)}
      '') cfg.credentials);
    };

    # Environment variables
    home.sessionVariables = {
      AWS_PAGER = if cfg.enablePager then "less" else "";
      AWS_CLI_HISTORY = if cfg.cliHistoryEnabled then "enabled" else "disabled";
    } // (optionalAttrs (cfg.region != null) {
      AWS_DEFAULT_REGION = cfg.region;
    }) // (optionalAttrs (cfg.profile != null) {
      AWS_PROFILE = cfg.profile;
    });


  };
}
