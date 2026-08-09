{ config, lib, namespace, pkgs, inputs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.neovim;
in
{
  options.${namespace}.programs.system.neovim = mkSystemToolOptions "Neovim";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Neovim" cfg;

    programs.neovim.enable = true;
    programs.lazyvim = {
      enable = true;

      extraPackages = with pkgs; [
        nixd       # Nix LSP
        alejandra  # Nix formatter
      ];

      plugins = {
        colorscheme = inputs.lazyvim.lib.lazyConfig [
        {
          plugin = "gbprod/nord.nvim";
        }
        {
          plugin = "LazyVim/LazyVim";
          opts = { colorscheme = "nord"; };
        }
        ];
      };
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      v = "nvim";
      vim = "nvim";
    });
  };
}
