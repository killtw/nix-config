# Media Suite - Media and entertainment applications
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.media;

  # Available media applications
  availableModules = [
    "spotify"
    "ffmpeg"
    "iina"
    "sonos"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.media = mkDarwinSuiteOptions "media" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Media packages based on enabled applications
    ] ++ (if elem "ffmpeg" (subtractLists cfg.excludeModules cfg.modules) then [
      ffmpeg
    ] else []) ++ (if elem "iina" (subtractLists cfg.excludeModules cfg.modules) then [
      iina
    ] else []) ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "spotify" (subtractLists cfg.excludeModules cfg.modules) then [
        "spotify"
      ] else []) ++ (if elem "sonos" (subtractLists cfg.excludeModules cfg.modules) then [
        "sonos"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
