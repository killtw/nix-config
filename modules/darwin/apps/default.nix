# Darwin applications and packages module
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.apps;
in
{
  options.${namespace}.apps = {
    enable = mkBoolOpt true "Whether to enable applications configuration.";

    # Additional Homebrew configuration
    extraTaps = mkListOpt types.str [] "Additional Homebrew taps to add";
    extraBrews = mkListOpt types.str [] "Additional Homebrew brews to install";
    extraCasks = mkListOpt types.str [] "Additional Homebrew casks to install";
    extraMasApps = mkAttrsOpt {} "Additional Mac App Store applications to install";

    # Additional system packages
    extraPackages = mkListOpt types.package [] "Additional system packages to install";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        # Core system packages
        devbox
        ffmpeg
        git
        iina
        wget
      ] ++ cfg.extraPackages;

      variables = {
        EDITOR = "vim";
        HOMEBREW_NO_ANALYTICS = "1";
      };
    };

    homebrew = {
      enable = true;

      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
      };

      taps = [] ++ cfg.extraTaps;

      brews = [
        "bitwarden-cli"
      ] ++ cfg.extraBrews;

      casks = [
        # Development
        "visual-studio-code"
        "tableplus"
        "lens"

        # Productivity
        "arc"
        "raycast"

        # Media
        "spotify"
        "sonos"

        # System
        "adguard"
        "airbuddy"
        "betterdisplay"
        "jordanbaird-ice"
        "surge"

        # Communication
        "dingtalk"
      ] ++ cfg.extraCasks;

      masApps = {
        # Productivity
        Bitwarden = 1352778147;
        Keynote = 409183694;
        Numbers = 409203825;
        Pages = 409201541;
        PopClip = 445189367;
        "The Unarchiver" = 425424353;

        # Communication
        LINE = 539883307;
      } // cfg.extraMasApps;
    };
  };


}
