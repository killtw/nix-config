{ config, lib, namespace, pkgs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.neovim;
in
{
  options.${namespace}.programs.system.neovim = mkSystemToolOptions "Neovim";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Neovim" cfg;

    programs.lazyvim.enable = true;

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      v = "nvim";
      vim = "nvim";
    });
  };
}
