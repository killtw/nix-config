# Common Suite - Essential applications for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common applications
  availableModules = [
    "bitwarden-cli"
  ];
in
{
  # Use the Darwin suite options helper from lib
  options.${namespace}.suites.common = mkDarwinSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Configure system packages
    environment.systemPackages = with pkgs; [
      # System packages based on enabled applications
      obsidian
    ] ++ cfg.extraPackages;

    # Configure Homebrew
    homebrew = {
      enable = true;

      taps = [] ++ cfg.extraTaps;

      brews = [
        "bitwarden-cli"
        "mole"
      ] ++ cfg.extraBrews;

      casks = [
        "arc"
        "chatgpt"
        "codex"
        "codexbar"
        "vorssaint"
        "zed"
      ] ++ cfg.extraCasks;

      masApps = {
        Bitwarden = 1352778147;
        "Obsidian Web Clipper" = 6720708363;
      } // cfg.extraMasApps;
    };
  };
}
