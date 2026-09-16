# System Suite - System utilities and tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.system;

  # Available system applications
  availableModules = [
    "airbuddy"
    "betterdisplay"
    "popclip"
    "surge"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.system = mkDarwinSuiteOptions "system" availableModules;

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    # Configure system packages
    environment.systemPackages = with pkgs; [
      # System packages can be added here
      git
      ripgrep
      wget
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [
        "herdr"
        "mas"
      ] ++ cfg.extraBrews;

      casks = [
        "syntax-highlight"
      ] ++ (if elem "airbuddy" (subtractLists cfg.excludeModules cfg.modules) then [
        "airbuddy"
      ] else []) ++ (if elem "betterdisplay" (subtractLists cfg.excludeModules cfg.modules) then [
        "betterdisplay"
      ] else []) ++ (if elem "popclip" (subtractLists cfg.excludeModules cfg.modules) then [
        "popclip"
      ] else []) ++ (if elem "surge" (subtractLists cfg.excludeModules cfg.modules) then [
        "surge"
      ] else []) ++ cfg.extraCasks;

      masApps = {
        "The Unarchiver" = 425424353;
      } // cfg.extraMasApps;
    };
  };
}
