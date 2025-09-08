# Creative Suite - Creative and design tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.creative;

  # Available creative applications
  availableModules = [
    "bambu-studio"
    "thumbhost3mf"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.creative = mkDarwinSuiteOptions "creative" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # Creative packages can be added here
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [] ++ cfg.extraBrews;

      casks = [] ++ (if elem "bambu-studio" (subtractLists cfg.excludeModules cfg.modules) then [
        "bambu-studio"
      ] else []) ++ (if elem "thumbhost3mf" (subtractLists cfg.excludeModules cfg.modules) then [
        "thumbhost3mf"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
