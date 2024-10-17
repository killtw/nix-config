{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    pkgs.devenv
    wget
  ];

  environment.variables.EDITOR = "vim";

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };

    taps = [];

    brews = [
      "bitwarden-cli"
      "warrensbox/tap/tfswitch"
    ];

    casks = [
      "font-sauce-code-pro-nerd-font"

      "qlimagesize"
      "qlmarkdown"
      "qlstephen"
      "quicklook-csv"
      "quicklook-json"

      "adguard"
      "airbuddy"
      # "appcleaner"
      "arc"
      "dingtalk"
      # "dozer"
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
}
