{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    devbox
    wget
  ];

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
      "qlimagesize"
      "qlmarkdown"
      "qlstephen"
      "quicklook-csv"
      "quicklook-json"

      "adguard"
      "airbuddy"
      "arc"
      "ferdium"
      "iina"
      "itsycal"
      "jordanbaird-ice"
      "karabiner-elements"
      "raycast"
      "sonos"
      "spotify"
      "steam"
      "surge"
      # "thor"

      "dingtalk"
      "lens"
      "phpstorm"
      # "postman"
      "tableplus"
      # "visual-studio-code"
      "windsurf"
    ];

    masApps = {
      Bitwarden = 1352778147;
      # CodePiper = 1669959741;
      Reeder = 1529448980;
      Pages = 409201541;
      # "Spark Desktop" = 6445813049;
      Keynote = 409183694;
      LINE = 539883307;
      "The Unarchiver" = 425424353;
      PopClip = 445189367;
      Numbers = 409203825;
    };
  };

  environment.variables = {
    EDITOR = "vim";
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
