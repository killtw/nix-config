# Fzf fuzzy finder module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.fzf;
in
{
  options.${namespace}.programs.system.fzf = mkSystemToolOptions "Fzf" // {
    # Fzf-specific options
    defaultCommand = mkStrOpt "fd --type f --hidden --follow --exclude .git" "Default command for fzf";
    defaultOptions = mkListOpt types.str [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ] "Default options for fzf";

    colors = mkAttrsOpt {
      "bg+" = "#313244";
      "bg" = "#1e1e2e";
      "spinner" = "#f5e0dc";
      "hl" = "#f38ba8";
      "fg" = "#cdd6f4";
      "header" = "#f38ba8";
      "info" = "#cba6ac";
      "pointer" = "#f5e0dc";
      "marker" = "#f5e0dc";
      "fg+" = "#cdd6f4";
      "prompt" = "#cba6ac";
      "hl+" = "#f38ba8";
    } "Color scheme for fzf";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Fzf" cfg;

    programs.fzf = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.fzf;

      enableZshIntegration = true;

      defaultCommand = cfg.defaultCommand;
      defaultOptions = cfg.defaultOptions ++ [
        "--color=${concatStringsSep "," (mapAttrsToList (name: value: "${name}:${value}") cfg.colors)}"
      ];
    };

    # Additional packages for better fzf experience
    home.packages = with pkgs; [
      fd  # Better find alternative
      ripgrep  # Better grep alternative
    ];
  };
}
