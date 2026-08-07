# Zoxide smart cd replacement module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.bun;
in
{
  options.${namespace}.programs.development.bun = mkSystemToolOptions "Bun" // {
    # Bun-specific settings
    settings = mkAttrsOpt {} "Additional settings for bun";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Bun" cfg;

    programs.bun = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.bun;

      enableGitIntegration = true;

      settings = cfg.settings;
    };
  };
}
