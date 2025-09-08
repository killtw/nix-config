# Gaming Suite - Gaming applications and tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.gaming;

  # Available gaming applications
  availableModules = [
    "sony-ps-remote-play"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.gaming = mkDarwinSuiteOptions "gaming" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Gaming packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "sony-ps-remote-play" (subtractLists cfg.excludeModules cfg.modules) then [
        "sony-ps-remote-play"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
