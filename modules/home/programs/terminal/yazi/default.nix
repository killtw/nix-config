{ config, lib, namespace, pkgs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.yazi;
in
{
  options.${namespace}.programs.terminal.yazi = mkTerminalOptions "Yazi";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Yazi" cfg;

    programs.yazi = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.yazi;
      enableZshIntegration = true;
    };
  };
}
