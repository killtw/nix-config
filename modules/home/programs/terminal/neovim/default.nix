{ config, lib, namespace, pkgs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.neovim;
in
{
  options.${namespace}.programs.terminal.neovim = {
    enable = mkEnableOption "Neovim with LazyVim";
    package = mkPackageOptNull "Package to use for Neovim";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Neovim" cfg;

    programs.lazyvim.enable = true;
    programs.neovim.package = mkForce (mkPackageWithFallback cfg pkgs.neovim-unwrapped);
  };
}
