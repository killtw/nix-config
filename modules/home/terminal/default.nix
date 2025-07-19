# Home Manager terminal applications module
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.terminal-config;
in
{
  options.programs.terminal-config = {
    enable = mkEnableOption "terminal applications configuration";
  };

  config = mkIf cfg.enable {
    programs = {
      # Alacritty terminal emulator
      alacritty = {
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

          cursor = {
            style = {
              shape = "Block";
              blinking = "Off";
            };
            vi_mode_style = {
              shape = "Block";
              blinking = "Off";
            };
          };

          window = {
            decorations = "buttonless";
            opacity = 0.9;
            blur = true;
            option_as_alt = "Both";
            padding = {
              x = 10;
              y = 10;
            };
          };

          font = {
            normal = {
              family = "SauceCodePro Nerd Font";
              style = "Regular";
            };
            bold = {
              family = "SauceCodePro Nerd Font";
              style = "Bold";
            };
            italic = {
              family = "SauceCodePro Nerd Font";
              style = "Italic";
            };
            bold_italic = {
              family = "SauceCodePro Nerd Font";
              style = "Bold Italic";
            };
            size = 14;
          };

          colors = {
            primary = {
              background = "#16151B";
              foreground = "#edecee";
            };
            normal = {
              black = "#16151B";
              red = "#f7768e";
              green = "#9ece6a";
              yellow = "#e0af68";
              blue = "#7aa2f7";
              magenta = "#bb9af7";
              cyan = "#7dcfff";
              white = "#a9b1d6";
            };
            bright = {
              black = "#414868";
              red = "#f7768e";
              green = "#9ece6a";
              yellow = "#e0af68";
              blue = "#7aa2f7";
              magenta = "#bb9af7";
              cyan = "#7dcfff";
              white = "#c0caf5";
            };
          };
        };
      };

      # Tmux terminal multiplexer
      tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "xterm-256color";
        prefix = "'C-\\'";

        mouse = true;
        aggressiveResize = false;
        escapeTime = 0;
        historyLimit = 100000;
        keyMode = "vi";
        resizeAmount = 5;
        customPaneNavigationAndResize = true;
        disableConfirmationPrompt = true;
        baseIndex = 1;

        plugins = with pkgs; [
          tmuxPlugins.sensible
        ];

        extraConfig = ''
          # renumber windows sequentially after closing any of them
          set-option -g renumber-windows off

          # auto window rename
          set-option -g automatic-rename on

          # enable activity alerts
          set-window-option -g monitor-activity off
          set-option -g visual-activity off

          # enable clipboard
          set-option -g set-clipboard on

          # truecolor support
          set-option -ga terminal-overrides ",xterm-256color:Tc"

          # go to last window
          bind-key ^ last-window

          # splitting panes with current path
          bind-key c new-window -c "#{pane_current_path}"
          bind-key | split-window -h -c "#{pane_current_path}"
          bind-key '"' split-window -v -c "#{pane_current_path}"

          setw -g mode-style fg=#e9eef9,bg=#312D45
          set-option -g status-style "fg=#edecee,bg=#16151B"
          set-option -g status-left-style "fg=#edecee,bg=#16151B"
          set-option -g status-right-style "fg=#edecee,bg=#16151B"

          set-option -g status-left-length 100
          set-option -g status-right-length 100

          set-option -g status-left "#[fg=#edecee]  #S  "
          set-option -g status-right "#[fg=#edecee]  %Y-%m-%d %H:%M  "

          set-option -g window-status-style "fg=#16151B,bg=#16151B"
          set-option -g window-status-current-style "fg=#edecee,bg=#49556a"
          set-option -g window-status-activity-style "fg=#edecee,bg=#16151B"

          set-option -g window-status-format '#[fg=#edecee]  #I  '
          set-option -g window-status-current-format '#[fg=#edecee]  #I  '
          set-option -g window-status-separator ""

          bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel

          set -gu default-command
          set -g default-shell "$SHELL"
        '';
      };
    };
  };
}
