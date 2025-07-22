# Zoxide smart cd replacement module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.zoxide;
in
{
  options.${namespace}.programs.system.zoxide = mkSystemToolOptions "Zoxide" // {
    # Zoxide-specific options
    options = mkListOpt types.str [] "Additional options for zoxide";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Zoxide" cfg;

    programs.zoxide = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.zoxide;

      enableZshIntegration = true;

      options = cfg.options;
    };

    # Shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      cd = "z";
      cdi = "zi";
    });
  };
}
