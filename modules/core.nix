{ pkgs, lib, ... }: {
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # Use this instead of services.nix-daemon.enable if you
  # don't wan't the daemon service to be managed for you.
  # nix.useDaemon = true;

  nix = {
    package = pkgs.nix;

    # do garbage collection weekly to keep disk usage low
    gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 7d";
    };

    optimise.automatic = true;

    # Necessary for using flakes on this system.
    # Disable auto-optimise-store because of this issue:
    #   https://github.com/NixOS/nix/issues/7273
    # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
