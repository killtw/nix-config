# Ghostty terminal emulator module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.ghostty;
in
{
  options.${namespace}.programs.terminal.ghostty = mkTerminalOptions "Ghostty";

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Ghostty" cfg;

    programs.ghostty = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.ghostty-bin;

      settings = {
        # Font
        font-family = "SauceCodePro Nerd Font";
        font-size = 13;
        font-thicken = true;

        theme = "Nord";
        background = "2a2f3a";

        # Cursor
        cursor-style = "bar";
        cursor-style-blink = false;
        scrollback-limit = 100000;
        shell-integration-features = "no-cursor";

        # Window
        window-padding-x = 18;
        window-padding-y = 16;
        window-decoration = true;
        window-theme = "auto";

        mouse-scroll-multiplier = 4;

        # Clipboard
        clipboard-read = "allow";
        clipboard-write = "allow";

        initial-command = "${pkgs.zsh}/bin/zsh -l -c \"/opt/homebrew/bin/herdr\"";

        # Forward macOS shortcuts to Herdr's default Ctrl-B keybindings.
        keybind = [
          # macos/chrome-style herdr actions
          "cmd+KeyT=text:\\x02c" # keys.new_tab (prefix+c)
          "cmd+t=unbind"
          "cmd+KeyN=text:\\x02N" # keys.new_workspace (prefix+shift+n)
          "cmd+n=unbind"
          # cmd+w closes the focused pane; cmd+shift+w force-closes the whole tab
          "cmd+KeyW=text:\\x02x"
          "cmd+w=unbind"
          "cmd+shift+KeyW=text:\\x02X"
          "cmd+shift+w=unbind"

          # splits: cmd+d vertical, cmd+shift+d horizontal
          "cmd+KeyD=text:\\x02v"
          "cmd+d=unbind"
          "cmd+shift+KeyD=text:\\x02-"
          "cmd+shift+d=unbind"

          "cmd+KeyS=text:\\x02b"
          "cmd+s=unbind"

          "cmd+digit_1=text:\\x1b[49;6u" # keys.switch_tab (prefix+1..9)
          "cmd+1=text:\\x1b[49;6u"
          "cmd+digit_2=text:\\x1b[50;6u"
          "cmd+2=text:\\x1b[50;6u"
          "cmd+digit_3=text:\\x1b[51;6u"
          "cmd+3=text:\\x1b[51;6u"
          "cmd+digit_4=text:\\x1b[52;6u"
          "cmd+4=text:\\x1b[52;6u"
          "cmd+digit_5=text:\\x1b[53;6u"
          "cmd+5=text:\\x1b[53;6u"
          "cmd+digit_6=text:\\x1b[54;6u"
          "cmd+6=text:\\x1b[54;6u"
          "cmd+digit_7=text:\\x1b[55;6u"
          "cmd+7=text:\\x1b[55;6u"
          "cmd+digit_8=text:\\x1b[56;6u"
          "cmd+8=text:\\x1b[56;6u"
          "cmd+digit_9=text:\\x1b[57;6u"
          "cmd+9=text:\\x1b[57;6u"
        ];
      };

      installVimSyntax = true;
      installBatSyntax = true;

      enableZshIntegration = true;
    };
  };
}
