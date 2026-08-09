{ config, lib, namespace, pkgs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.lazygit;
in
{
  options.${namespace}.programs.terminal.lazygit = mkTerminalOptions "Lazygit";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Lazygit" cfg;

    programs.lazygit = {
      enable = true;

      enableZshIntegration = true;
    };
  };
}
