# Common Suite - Essential applications for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common modules
  availableModules = [
    "core-packages"
    "browser"
    "launcher"
    "security"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.common = mkDarwinSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Core packages (always enabled if common suite is enabled)
    ] ++ (if elem "core-packages" (subtractLists cfg.excludeModules cfg.modules) then [
      git
      wget
    ] else []) ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ (if elem "core-packages" (subtractLists cfg.excludeModules cfg.modules) then [
        "bitwarden-cli"
      ] else []) ++ cfg.extraBrews;

      casks = [] ++ (if elem "browser" (subtractLists cfg.excludeModules cfg.modules) then [
        "arc"
      ] else []) ++ (if elem "launcher" (subtractLists cfg.excludeModules cfg.modules) then [
        "raycast"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // (if elem "security" (subtractLists cfg.excludeModules cfg.modules) then {
        Bitwarden = 1352778147;
        "The Unarchiver" = 425424353;
      } else {}) // cfg.extraMasApps;
    };
  };
}
