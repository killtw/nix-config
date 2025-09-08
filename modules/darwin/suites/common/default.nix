# Common Suite - Essential applications for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common applications
  availableModules = [
    "bitwarden-cli"
    "raycast"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.common = mkDarwinSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # System packages based on enabled applications
      git
      wget
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [
        "bitwarden-cli"
      ] ++ cfg.extraBrews;

      casks = [
        "arc"
        "visual-studio-code"
      ] ++ (if elem "raycast" (subtractLists cfg.excludeModules cfg.modules) then [
        "raycast"
      ] else []) ++ cfg.extraCasks;

      masApps = {
        Bitwarden = 1352778147;
        "The Unarchiver" = 425424353;
      } // cfg.extraMasApps;
    };
  };
}
