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
    "thaw"
    "rustdesk"
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
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "airbuddy" (subtractLists cfg.excludeModules cfg.modules) then [
        "airbuddy"
      ] else []) ++ (if elem "betterdisplay" (subtractLists cfg.excludeModules cfg.modules) then [
        "betterdisplay"
      ] else []) ++ (if elem "popclip" (subtractLists cfg.excludeModules cfg.modules) then [
        "popclip"
      ] else []) ++ (if elem "surge" (subtractLists cfg.excludeModules cfg.modules) then [
        "surge"
      ] else []) ++ (if elem "thaw" (subtractLists cfg.excludeModules cfg.modules) then [
        "thaw"
      ] else []) ++ (if elem "rustdesk" (subtractLists cfg.excludeModules cfg.modules) then [
        "rustdesk"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
