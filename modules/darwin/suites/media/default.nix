# Media Suite - Media and entertainment applications
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.media;

  # Available media modules
  availableModules = [
    "music"
    "video"
    "audio-system"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.media = mkDarwinSuiteOptions "media" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Media packages
    ] ++ (if elem "video" (subtractLists cfg.excludeModules cfg.modules) then [
      ffmpeg
      iina
    ] else []) ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "music" (subtractLists cfg.excludeModules cfg.modules) then [
        "spotify"
      ] else []) ++ (if elem "audio-system" (subtractLists cfg.excludeModules cfg.modules) then [
        "sonos"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
