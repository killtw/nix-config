# Eza file listing tool module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.eza;
in
{
  options.${namespace}.programs.system.eza = mkSystemToolOptions "Eza" // {
    # Eza-specific options
    enableGit = mkBoolOpt true "Show git status in listings";
    enableIcons = mkEnumOpt [ "auto" "null" ] "auto" "Show file type icons";
    enableHeader = mkBoolOpt true "Show column headers";

    defaultFlags = mkListOpt types.str [
      "--long"
      "--all"
      "--group-directories-first"
      "--time-style=long-iso"
    ] "Default flags for eza";

    colorMode = mkEnumOpt [ "auto" "always" "never" ] "auto" "Color mode";

    timeStyle = mkEnumOpt [ "default" "iso" "long-iso" "full-iso" "relative" ] "long-iso" "Time display style";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Eza" cfg;

    programs.eza = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.eza;

      enableZshIntegration = true;
      git = cfg.enableGit;
      icons = cfg.enableIcons;

      extraOptions = cfg.defaultFlags ++ [
        "--color=${cfg.colorMode}"
        "--time-style=${cfg.timeStyle}"
      ] ++ optional cfg.enableHeader "--header";
    };

    # Additional shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      ls = "eza";
      ll = "eza --long --all --group-directories-first";
      la = "eza --all";
      lt = "eza --tree";
      lg = "eza --long --all --group-directories-first --git";
      lh = "eza --long --all --group-directories-first --header";
      lr = "eza --long --all --group-directories-first --recurse";
      lm = "eza --long --all --group-directories-first --sort=modified";
      ls1 = "eza --oneline";
    });

  };
}
