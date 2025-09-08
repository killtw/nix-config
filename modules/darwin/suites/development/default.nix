# Development Suite - Development tools and IDEs
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;

  # Available development applications
  availableModules = [
    "visual-studio-code"
    "tableplus"
    "lens"
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

      casks = [] ++ (if elem "visual-studio-code" (subtractLists cfg.excludeModules cfg.modules) then [
        "visual-studio-code"
      ] else []) ++ (if elem "tableplus" (subtractLists cfg.excludeModules cfg.modules) then [
        "tableplus"
      ] else []) ++ (if elem "lens" (subtractLists cfg.excludeModules cfg.modules) then [
        "lens"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
