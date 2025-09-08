# Gaming Suite - Gaming applications and tools
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.gaming;

  # Available gaming applications
  availableModules = [];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.gaming = mkDarwinSuiteOptions "gaming" availableModules;

  config = mkIf cfg.enable {
    # Configure Homebrew
    homebrew = {
      enable = true;

      casks = [
        "sony-ps-remote-play"
        "steam"
      ] ++ cfg.extraCasks;
    };
  };
}
