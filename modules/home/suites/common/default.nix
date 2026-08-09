# Common Suite - Essential tools for all users
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.common;

  # Available common modules
  availableModules = [
    "alacritty"
    "ghostty"
    "herdr"
    "lazygit"
    "tmux"
  ];
in
{
  # Use the suite options helper from lib
  options.${namespace}.suites.common = mkSuiteOptions "common" availableModules;

  config = mkIf cfg.enable {
    # Enable common modules with default settings
    ${namespace}.programs = {
      development.git.enable = true;

      shell.zsh.enable = true;

      system = {
        bat.enable = true;
        eza.enable = true;
        fzf.enable = true;
        neovim.enable = true;
        starship.enable = true;
        zoxide.enable = true;
      };

      terminal = {
        alacritty = mkIf (elem "alacritty" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        ghostty = mkIf (elem "ghostty" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        herdr = mkIf (elem "herdr" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        lazygit = mkIf (elem "lazygit" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        tmux = mkIf (elem "tmux" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };
    };
  };
}
