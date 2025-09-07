# Productivity Suite - Productivity and office applications
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.productivity;

  # Available productivity modules
  availableModules = [
    "clipboard"
    "iwork"
    "utilities"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.productivity = mkDarwinSuiteOptions "productivity" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Productivity packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "clipboard" (subtractLists cfg.excludeModules cfg.modules) then [
        "popclip"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // (if elem "iwork" (subtractLists cfg.excludeModules cfg.modules) then {
        Keynote = 409183694;
        Numbers = 409203825;
        Pages = 409201541;
      } else {}) // cfg.extraMasApps;
    };
  };
}
