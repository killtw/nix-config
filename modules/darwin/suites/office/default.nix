# Office Suite - Office and office applications
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.office;

  # Available office applications
  availableModules = [];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.office = mkDarwinSuiteOptions "office" availableModules;

  config = mkIf cfg.enable {
    # Configure Homebrew
    homebrew = {
      enable = true;

      masApps = {
        Keynote = 409183694;
        Numbers = 409203825;
        Pages = 409201541;
      } // cfg.extraMasApps;
    };
  };
}
