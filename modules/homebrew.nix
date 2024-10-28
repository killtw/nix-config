{ inputs, username, ... }: {
  homebrew = {
    enable = true;

    onActivation = {
      # autoUpdate = true;
      cleanup = "zap";
    };

    global = {
      autoUpdate = true;
    };

    taps = [];

    brews = [
      "bitwarden-cli"
      "warrensbox/tap/tfswitch"
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
      "surge"
      # "thor"

      "dingtalk"
      "google-cloud-sdk"
      "lens"
      "phpstorm"
      "postman"
      "tableplus"
      "visual-studio-code"
    ];

    masApps = {
      Bitwarden = 1352778147;
      CodePiper = 1669959741;
      Reeder = 1529448980;
      Pages = 409201541;
      "Spark Desktop" = 6445813049;
      Keynote = 409183694;
      LINE = 539883307;
      "The Unarchiver" = 425424353;
      PopClip = 445189367;
      Numbers = 409203825;
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;

    taps = {};

    mutableTaps = true;
    autoMigrate = true;
  };
}
