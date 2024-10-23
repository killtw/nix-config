{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.${namespace}.system.interface;
in
{
  options.${namespace}.system.interface = {
    enable = mkEnableOption "macOS interface";
  };

  config = mkIf cfg.enable {
    system = {
      default = {
        dock = {
          autohide = true;
          show-recents = false;
        };

        CustomUserPreferences = {
          finder = {
            DisableAllAnimations = true;
            _FXSortFoldersFirst = true;
          };

          NSGlobalDomain = {
            AppleSpacesSwitchOnActivate = false;
            WebKitDeveloperExtras = true;
          };
        };

        loginwindow = {
          GuestEnabled = false;
          # show name instead of username
          SHOWFULLNAME = false;
        };

        screencapture = {
          location = "~/Desktop";
          type = "png";
        };
      };
    };
  };
}
