# Creative Suite - Creative and design tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.creative;

  # Available creative modules
  availableModules = [
    "3d-printing"
    "design"
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

      casks = [] ++ (if elem "3d-printing" (subtractLists cfg.excludeModules cfg.modules) then [
        "bambu-studio"
        "thumbhost3mf"
      ] else []) ++ cfg.extraCasks;

      masApps = {} // cfg.extraMasApps;
    };
  };
}
