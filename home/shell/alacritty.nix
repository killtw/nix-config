{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      general.live_config_reload = true;

      env.TERM = "xterm-256color";

      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "-l"
          "-c"
          "tmux attach || tmux"
        ];
      };

      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
        save_to_clipboard = true;
      };

      colors = {
        # 如果为‘true’，则使用亮色变体绘制粗体文本。
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

      font = {
        size = 11.0;

        normal = {
          family = "SauceCodePro Nerd Font";
          style = "Regular";
        };

        offset = {
          x = 0;
          y = 9;
        };

        glyph_offset = {
          x = 0;
          y = 3;
        };
      };

      window = {
        padding = {
          x = 18;
          y = 16;
        };

        dynamic_padding = false;
        decorations = "transparent";
      };

      scrolling = {
        # 回滚缓冲区中的最大行数,指定“0”将禁用滚动。
        history = 100000;
        # 滚动行数
        multiplier = 4;
      };

      cursor.style.shape = "Beam";

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
          chars = "\\u001Bb"; # Skip word left
        }
        {
          key = "Right";
          mods= "Alt";
          chars = "\\u001Bf"; # Skip word right
        }
        {
          key = "Left";
          mods = "Command";
          chars = "\\u0001"; # Home
        }
        {
          key = "Right";
          mods = "Command";
          chars = "\\u0005"; # End
        }
        {
          key = "Back";
          mods = "Command";
          chars = "\\u0015"; # Delete line
        }
        {
          key = "Back";
          mods = "Alt";
          chars = "\\u001B\\u007F"; # Delete word
        }
        {
          key = "T";
          mods = "Command";
          chars = "\\u001Cc"; # new tab with default shell
        }
        {
          key = "W";
          mods = "Command";
          chars = "\\u001C&"; # close the tab
        }
        {
          key = "LBracket";
          mods = "Command|Shift";
          chars = "\\u001Cp"; # go to previous tab
        }
        {
          key = "RBracket";
          mods = "Command|Shift";
          chars = "\\u001Cn"; # go to next tab
        }
        {
          key = "Key1";
          mods = "Command";
          chars = "\\u001C1"; # go to tab 1..9
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

    };
  };
}
