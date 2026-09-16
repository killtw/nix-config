# Mise development tool module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.mise;
in
{
  options.${namespace}.programs.development.mise = mkDevelopmentToolOptions "Mise";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Mise" cfg;

    programs.mise = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.mise;
      enableZshIntegration = true;
    } // cfg.extraConfig;

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable cfg.aliases;
  };
}
