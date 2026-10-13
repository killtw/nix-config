# Printing Suite - Printing and design tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.printing;

  # Available printing applications
  availableModules = [
    "orcaslicer"
    "thumbhost3mf"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.printing = mkDarwinSuiteOptions "printing" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Printing packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "thumbhost3mf" (subtractLists cfg.excludeModules cfg.modules) then [
        "thumbhost3mf"
      ] else []) ++ (if elem "orcaslicer" (subtractLists cfg.excludeModules cfg.modules) then [
        "orcaslicer"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
