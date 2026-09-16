# Development Suite - Development tools and IDEs
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;

  # Available development applications
  availableModules = [
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.development = mkDarwinSuiteOptions "development" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Development packages can be added here
      bun
      devbox
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [
        "gh"
      ] ++ cfg.extraBrews;

      casks = [
        "dbx"
      ] ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
