{
  config,
  lib,
  namespace
}:
let
  inherit (lib) mkIf;
  cfg = config.${namespace}.nix;
in
{
  config = mkIf cfg.enable {
    nix = {
      package = cfg.package;

      gc = {
          automatic = true;
          interval = {
            Day = 7;
          };
          options = "--delete-older-than 7d";
      };

      optimise.automatic = true;

      # Necessary for using flakes on this system.
      # Disable auto-optimise-store because of this issue:
      #   https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
      };

      extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
    };
  };
}
