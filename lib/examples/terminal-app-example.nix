# Example: Terminal application module using namespace and lib functions
# This demonstrates how to create a namespaced Home Manager module
# Location: modules/home/terminal/alacritty/default.nix

{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.terminal.alacritty;
in
{
  # Use the terminal options helper from lib
  options.${namespace}.terminal.alacritty = mkTerminalOptions "Alacritty" // {
    # Add application-specific options
    shell = mkOption {
      type = types.str;
      default = "${pkgs.zsh}/bin/zsh";
      description = "Default shell for Alacritty";
    };
    
    startupMode = mkEnumOpt [ "Windowed" "Maximized" "Fullscreen" ] "Windowed" 
      "Window startup mode";
    
    opacity = mkFloatOpt 1.0 "Window opacity (0.0 - 1.0)";
    
    keybindings = mkListOpt types.attrs [] "Custom keybindings";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Alacritty" cfg;
    
    programs.alacritty = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.alacritty;
      
      settings = {
        general.live_config_reload = true;
        
        env.TERM = "xterm-256color";
        
        terminal.shell = {
          program = cfg.shell;
          args = [ "-l" "-c" "tmux attach || tmux" ];
        };
        
        font = {
          size = cfg.fontSize;
          normal.family = cfg.fontFamily;
        };
        
        window = {
          startup_mode = cfg.startupMode;
          opacity = cfg.opacity;
          padding = { x = 18; y = 16; };
          decorations = "transparent";
        };
        
        # Apply theme-based colors
        colors = if cfg.theme == "dark" then {
          primary = {
            background = "#26292c";
            foreground = "#cfd2d0";
          };
          normal = {
            black = "#000000";
            red = "#d77b79";
            green = "#c1c67a";
            yellow = "#f3cf86";
            blue = "#92b1c9";
            magenta = "#c0a6c7";
            cyan = "#9ac8c3";
            white = "#fffefe";
          };
        } else {
          primary = {
            background = "#ffffff";
            foreground = "#000000";
          };
          normal = {
            black = "#000000";
            red = "#cc0000";
            green = "#4e9a06";
            yellow = "#c4a000";
            blue = "#3465a4";
            magenta = "#75507b";
            cyan = "#06989a";
            white = "#d3d7cf";
          };
        };
        
        # Custom keybindings
        keyboard.bindings = [
          {
            key = "R";
            mods = "Command";
            mode = "~Vi|~Search";
            action = "ClearHistory";
          }
          {
            key = "N";
            mods = "Command";
            action = "SpawnNewInstance";
          }
        ] ++ cfg.keybindings;
        
        # Merge extra configuration
      } // cfg.extraConfig;
    };
  };
}
