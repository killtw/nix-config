{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.tools.homebrew;
in
{
  options.${namespace}.tools.homebrew = {
    enable = mkBoolOpt false "Whether or not to enable homebrew.";
    masEnable = mkBoolOpt false "Whether or not to enable Mac App Store downloads.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;

      global = {
        brewfile = true;
        autoUpdate = false;
      };

      onActivation = {
        autoUpdate = false;
        cleanup = "uninstall";
        # cleanup = "zap";
        upgrade = true;
      };

      taps = [];
      brews = [];
      casks = [
        # "font-sauce-code-pro-nerd-font"

        "qlimagesize"
        "qlmarkdown"
        "qlstephen"
        "quicklook-csv"
        "quicklook-json"

        "adguard"
        "airbuddy"
        # "appcleaner"
        "arc"
        "bitwarden-cli"
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
  };
}
