# Productivity Suite - Productivity and office applications
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.productivity;

  # Available productivity applications
  availableModules = [
    "popclip"
    "Keynote"
    "Numbers"
    "Pages"
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

      casks = [] ++ (if elem "popclip" (subtractLists cfg.excludeModules cfg.modules) then [
        "popclip"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // (if elem "Keynote" (subtractLists cfg.excludeModules cfg.modules) then {
        Keynote = 409183694;
      } else {}) // (if elem "Numbers" (subtractLists cfg.excludeModules cfg.modules) then {
        Numbers = 409203825;
      } else {}) // (if elem "Pages" (subtractLists cfg.excludeModules cfg.modules) then {
        Pages = 409201541;
      } else {}) // cfg.extraMasApps;
    };
  };
}
