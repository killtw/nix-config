# System Suite - System utilities and tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.system;

  # Available system modules
  availableModules = [
    "utilities"
    "monitoring"
    "network"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.system = mkDarwinSuiteOptions "system" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # System packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "utilities" (subtractLists cfg.excludeModules cfg.modules) then [
        "airbuddy"
        "betterdisplay"
        "jordanbaird-ice"
      ] else []) ++ (if elem "network" (subtractLists cfg.excludeModules cfg.modules) then [
        "surge"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
