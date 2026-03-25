# Ghostty terminal emulator module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.ghostty;

  # Convert attrset to Ghostty config format (key = value per line)
  toGhosttyConfig = attrs:
    concatStringsSep "\n" (
      mapAttrsToList (k: v:
        "${k} = ${
          if builtins.isBool v then (if v then "true" else "false")
          else if builtins.isInt v then toString v
          else if builtins.isFloat v then toString v
          else toString v
        }"
      ) attrs
    );

  # Default keybindings ported from Alacritty
  defaultKeybindings = [
    "super+r=text:\\x0c"               # Clear screen
    "super+shift+w=quit"               # Quit terminal
    "super+n=new_window"               # New window
    "alt+left=text:\\x1b\\x62"        # Word left
    "alt+right=text:\\x1b\\x66"       # Word right
    "super+left=text:\\x01"            # Line start
    "super+right=text:\\x05"           # Line end
    "super+backspace=text:\\x15"       # Delete to line start
    "alt+backspace=text:\\x1b\\x7f"   # Delete word
    "super+t=text:\\x1c\\x63"         # tmux: new window
    "super+w=text:\\x1c\\x26"         # tmux: close window
    "super+shift+[=text:\\x1c\\x70"   # tmux: prev window
    "super+shift+]=text:\\x1c\\x6e"   # tmux: next window
    "super+1=text:\\x1c\\x31"         # tmux: window 1
    "super+2=text:\\x1c\\x32"         # tmux: window 2
    "super+3=text:\\x1c\\x33"         # tmux: window 3
    "super+4=text:\\x1c\\x34"         # tmux: window 4
    "super+5=text:\\x1c\\x35"         # tmux: window 5
    "super+6=text:\\x1c\\x36"         # tmux: window 6
    "super+7=text:\\x1c\\x37"         # tmux: window 7
    "super+8=text:\\x1c\\x38"         # tmux: window 8
    "super+9=text:\\x1c\\x39"         # tmux: window 9
  ];

  baseSettings = {
    font-family = cfg.fontFamily;
    font-size = cfg.fontSize;
    background-opacity = cfg.opacity;
    theme = if cfg.theme == "dark" then "GruvboxDark"
            else if cfg.theme == "light" then "GruvboxLight"
            else "GruvboxLight";
    cursor-style = "bar";
    cursor-style-blink = false;
    scrollback-limit = 100000;
    window-decoration = false;
    macos-titlebar-style = "hidden";
    shell-integration-features = "no-cursor";
    window-padding-x = 18;
    window-padding-y = 16;
    mouse-scroll-multiplier = 4;
    command = "${pkgs.zsh}/bin/zsh -l -c \"tmux attach || tmux\"";
  };
in
{
  options.${namespace}.programs.terminal.ghostty = mkTerminalOptions "Ghostty" // {
    opacity = mkFloatOpt 1.0 "Background opacity for Ghostty (0.0 to 1.0)";

    aliases = mkAttrsOpt {} "Shell aliases for Ghostty";

    keybindings = mkListOpt types.str [] "Additional keybindings for Ghostty (appended to defaults)";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Ghostty" cfg;

    # ghostty-bin repackages the official macOS .dmg for Nix on macOS.
    # pkgs.ghostty is the GTK build and is Linux-only.
    home.packages = [ (mkPackageWithFallback cfg pkgs.ghostty-bin) ];

    xdg.configFile."ghostty/config".text =
      toGhosttyConfig (baseSettings // cfg.extraConfig) + "\n\n" +
      concatMapStringsSep "\n" (k: "keybind = ${k}") (defaultKeybindings ++ cfg.keybindings) + "\n";

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable cfg.aliases;
  };
}

