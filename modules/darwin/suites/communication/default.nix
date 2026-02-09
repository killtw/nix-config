# Communication Suite - Communication and messaging apps
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.communication;

  # Available communication applications
  availableModules = [
    "dingtalk"
    "discord"
    "LINE"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.communication = mkDarwinSuiteOptions "communication" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Communication packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "dingtalk" (subtractLists cfg.excludeModules cfg.modules) then [
        "dingtalk"
      ] else []) ++ (if elem "discord" (subtractLists cfg.excludeModules cfg.modules) then [
        "discord"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // (if elem "LINE" (subtractLists cfg.excludeModules cfg.modules) then {
        LINE = 539883307;
      } else {}) // cfg.extraMasApps;
    };
  };
}
