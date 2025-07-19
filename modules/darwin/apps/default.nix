# Darwin applications and packages module
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.apps;
in
{
  options.${namespace}.apps = {
    enable = mkBoolOpt false "Whether to enable applications configuration.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        git
        devbox
        wget
        iina
        ffmpeg
      ];

      variables = {
        EDITOR = "vim";
        HOMEBREW_NO_ANALYTICS = "1";
      };
    };

    # services.tailscale.enable = true;

    homebrew = {
      enable = true;

      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
      };

      taps = [];

      brews = [
        "bitwarden-cli"
      ];

      casks = [
        "adguard"
        "airbuddy"
        "arc"
        "bambu-studio"
        "itsycal"
        "jordanbaird-ice"
        "karabiner-elements"
        "monitorcontrol"
        "sony-ps-remote-play"
        "raycast"
        "sonos"
        "spotify"
        "surge"
        "thumbhost3mf"

        "dingtalk"
        "lens"
        "tableplus"
        "visual-studio-code"
        "windsurf"
      ];

      masApps = {
        Bitwarden = 1352778147;
        Keynote = 409183694;
        LINE = 539883307;
        Numbers = 409203825;
        Pages = 409201541;
        PopClip = 445189367;
        # Reeder = 1529448980;
        "The Unarchiver" = 425424353;
      };
    };
  };
}
