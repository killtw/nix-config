{ pkgs, ... }: {
  programs.tmux = {
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

      # move panes to another window
      bind-key M-1 join-pane -t :1
      bind-key M-2 join-pane -t :2
      bind-key M-3 join-pane -t :3
      bind-key M-4 join-pane -t :4
      bind-key M-5 join-pane -t :5
      bind-key M-6 join-pane -t :6
      bind-key M-7 join-pane -t :7
      bind-key M-8 join-pane -t :8
      bind-key M-9 join-pane -t :9

      # Update default binding of `Enter` and `Space to also use copy-pipe
      unbind-key -T copy-mode-vi Enter
      unbind-key -T copy-mode-vi Space

      bind-key -T edit-mode-vi Up send-keys -X history-up
      bind-key -T edit-mode-vi Down send-keys -X history-down

      # begin selection as in Vim
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send -X rectangle-toggle

      # copy text in copy mode
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      # shortcut for synchronize-panes toggle
      bind-key I set-window-option synchronize-panes

      # status bar
      if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
      set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
      set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'

      set-option -g status-interval 1
      set-option -g status-position bottom
      set-option -g status-justify left
      set-option -g status-style none

      # status bar left right hidden
      set-option -g status-left ""
      set-option -g status-right ""
      # window bar style

      # set-option -g status off
      set-option -g window-status-style "fg=#16151B,bg=#16151B"
      set-option -g window-status-current-style "fg=#edecee,bg=#49556a"
      set-option -g window-status-activity-style "fg=#edecee,bg=#16151B"

      set-option -g window-status-format '#[fg=#edecee]  #I  '
      set-option -g window-status-current-format '#[fg=#edecee]  #I  '
      set-option -g window-status-separator ""

      bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel
    '';
  };
}
