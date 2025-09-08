# Common Suite - Essential applications for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common applications
  availableModules = [
    "git"
    "wget"
    "bitwarden-cli"
    "arc"
    "raycast"
    "Bitwarden"
    "The Unarchiver"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.common = mkDarwinSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # System packages based on enabled applications
    ] ++ (if elem "git" (subtractLists cfg.excludeModules cfg.modules) then [
      git
    ] else []) ++ (if elem "wget" (subtractLists cfg.excludeModules cfg.modules) then [
      wget
    ] else []) ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ (if elem "bitwarden-cli" (subtractLists cfg.excludeModules cfg.modules) then [
        "bitwarden-cli"
      ] else []) ++ cfg.extraBrews;

      casks = [] ++ (if elem "arc" (subtractLists cfg.excludeModules cfg.modules) then [
        "arc"
      ] else []) ++ (if elem "raycast" (subtractLists cfg.excludeModules cfg.modules) then [
        "raycast"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // (if elem "Bitwarden" (subtractLists cfg.excludeModules cfg.modules) then {
        Bitwarden = 1352778147;
      } else {}) // (if elem "The Unarchiver" (subtractLists cfg.excludeModules cfg.modules) then {
        "The Unarchiver" = 425424353;
      } else {}) // cfg.extraMasApps;
    };
  };
}
