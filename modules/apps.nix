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

    taps = [
      "homebrew/homebrew-cask"
    ];

    brews = [
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
      "alacritty"
      "appcleaner"
      "arc"
      "dingtalk"
      "dozer"
      "ferdium"
      "iina"
      "itsycal"
      "karabiner-elements"
      "raycast"
      "sonos"
      "spotify"
      "surge"
      "thor"

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
