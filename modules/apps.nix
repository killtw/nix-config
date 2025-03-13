{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      git
      devbox
      wget
      iina
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
      # "ferdium"
      "itsycal"
      "jordanbaird-ice"
      "karabiner-elements"
      "monitorcontrol"
      "raycast"
      "sonos"
      "spotify"
      "surge"

      "dingtalk"
      "lens"
      "phpstorm"
      "tableplus"
      "windsurf"
    ];

    masApps = {
      Bitwarden = 1352778147;
      Keynote = 409183694;
      LINE = 539883307;
      Numbers = 409203825;
      Pages = 409201541;
      PopClip = 445189367;
      Reeder = 1529448980;
      "The Unarchiver" = 425424353;
    };
  };
}
