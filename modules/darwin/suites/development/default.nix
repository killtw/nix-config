# Development Suite - Development tools and IDEs
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;

  # Available development modules
  availableModules = [
    "ide"
    "database"
    "containers"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.development = mkDarwinSuiteOptions "development" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Development packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "ide" (subtractLists cfg.excludeModules cfg.modules) then [
        "visual-studio-code"
      ] else []) ++ (if elem "database" (subtractLists cfg.excludeModules cfg.modules) then [
        "tableplus"
      ] else []) ++ (if elem "containers" (subtractLists cfg.excludeModules cfg.modules) then [
        "lens"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
