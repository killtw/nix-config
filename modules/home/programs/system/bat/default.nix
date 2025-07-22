# Bat file viewer module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.bat;
in
{
  options.${namespace}.programs.system.bat = mkSystemToolOptions "Bat" // {
    # Bat-specific options
    theme = mkStrOpt "Dracula" "Color theme for bat";

    showLineNumbers = mkBoolOpt true "Show line numbers";
    showHeader = mkBoolOpt true "Show file header";
    showGrid = mkBoolOpt false "Show grid";

    wrapMode = mkEnumOpt [ "auto" "never" "character" ] "auto" "Text wrapping mode";

    syntaxes = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional syntax definitions";
    };

    themes = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional themes";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Bat" cfg;

    programs.bat = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.bat;

      config = {
        theme = cfg.theme;
        style = concatStringsSep "," (
          optional cfg.showLineNumbers "numbers" ++
          optional cfg.showHeader "header" ++
          optional cfg.showGrid "grid" ++
          [ "changes" ]
        );
        wrap = cfg.wrapMode;
        pager = "less -FR";
      } // cfg.extraConfig;

      syntaxes = cfg.syntaxes;
      themes = cfg.themes;
    };

    # Shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      cat = "bat";
      less = "bat";
      more = "bat";
    });

    # Environment variables
    home.sessionVariables = {
      BAT_THEME = cfg.theme;
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };
}
