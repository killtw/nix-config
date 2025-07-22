# Common Suite - Essential tools for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common modules
  availableModules = [
    "git"
    "direnv"
    "zsh"
    "bat"
    "eza"
    "fzf"
    "zoxide"
    "starship"
    "alacritty"
    "tmux"
  ];
in
{
  # Use the suite options helper from lib
  options.${namespace}.suites.common = mkSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Enable common modules with default settings
    ${namespace}.programs = {
      development = {
        git = mkIf (elem "git" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        direnv = mkIf (elem "direnv" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };

      shell = {
        zsh = mkIf (elem "zsh" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };

      system = {
        bat = mkIf (elem "bat" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        eza = mkIf (elem "eza" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        fzf = mkIf (elem "fzf" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        zoxide = mkIf (elem "zoxide" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        starship = mkIf (elem "starship" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };

      terminal = {
        alacritty = mkIf (elem "alacritty" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        tmux = mkIf (elem "tmux" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };
    };
  };
}
