# Alacritty terminal emulator module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.alacritty;
in
{
  options.${namespace}.programs.terminal.alacritty = mkTerminalOptions "Alacritty";

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
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "-l" "-c" "tmux attach || tmux" ];
        };

        font = {
          size = 11.0;
          normal = {
            family = "SauceCodePro Nerd Font";
            style = "Regular";
          };
          offset = { x = 0; y = 9; };
          glyph_offset = { x = 0; y = 3; };
        };

        window = {
          startup_mode = "Windowed";
          opacity = 1.0;
          padding = { x = 18; y = 16; };
          dynamic_padding = false;
          decorations = "transparent";
        };

        scrolling = {
          history = 100000;
          multiplier = 4;
        };

        cursor.style.shape = "Beam";

        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
          save_to_clipboard = true;
        };

        colors = {
          draw_bold_text_with_bright_colors = false;
          primary = {
            background = "#26292c";
            foreground = "#cfd2d0";
          };
          cursor = {
            text = "#26292c";
            cursor = "#cfd2d0";
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
          search = {
            matches = {
              foreground = "#000000";
              background = "#ffffff";
            };
            focused_match = {
              foreground = "#ffffff";
              background = "#9F7AF5";
            };
          };
        };

        keyboard.bindings = [
          {
            key = "R";
            mods = "Command";
            mode = "~Vi|~Search";
            chars = "\\f";
          }
          {
            key = "R";
            mods = "Command";
            mode = "~Vi|~Search";
            action = "ClearHistory";
          }
          {
            key = "W";
            mods = "Command|Shift";
            action = "Quit";
          }
          {
            key = "N";
            mods = "Command";
            action = "SpawnNewInstance";
          }
          {
            key = "Left";
            mods = "Alt";
            chars = "\\u001Bb";
          }
          {
            key = "Right";
            mods = "Alt";
            chars = "\\u001Bf";
          }
          {
            key = "Left";
            mods = "Command";
            chars = "\\u0001";
          }
          {
            key = "Right";
            mods = "Command";
            chars = "\\u0005";
          }
          {
            key = "Back";
            mods = "Command";
            chars = "\\u0015";
          }
          {
            key = "Back";
            mods = "Alt";
            chars = "\\u001B\\u007F";
          }
          {
            key = "T";
            mods = "Command";
            chars = "\\u001Cc";
          }
          {
            key = "W";
            mods = "Command";
            chars = "\\u001C&";
          }
          {
            key = "LBracket";
            mods = "Command|Shift";
            chars = "\\u001Cp";
          }
          {
            key = "RBracket";
            mods = "Command|Shift";
            chars = "\\u001Cn";
          }
          {
            key = "Key1";
            mods = "Command";
            chars = "\\u001C1";
          }
          {
            key = "Key2";
            mods = "Command";
            chars = "\\u001C2";
          }
          {
            key = "Key3";
            mods = "Command";
            chars = "\\u001C3";
          }
          {
            key = "Key4";
            mods = "Command";
            chars = "\\u001C4";
          }
          {
            key = "Key5";
            mods = "Command";
            chars = "\\u001C5";
          }
          {
            key = "Key6";
            mods = "Command";
            chars = "\\u001C6";
          }
          {
            key = "Key7";
            mods = "Command";
            chars = "\\u001C7";
          }
          {
            key = "Key8";
            mods = "Command";
            chars = "\\u001C8";
          }
          {
            key = "Key9";
            mods = "Command";
            chars = "\\u001C9";
          }
          {
            key = "Back";
            action = "ReceiveChar";
          }
        ];
      } // cfg.extraConfig;
    };
  };
}
