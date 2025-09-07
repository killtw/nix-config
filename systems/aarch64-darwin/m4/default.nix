{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `aarch64-darwin`).
  target, # The Snowfall Lib target for this system (eg. `aarch64-darwin`).
  format, # A normalized name for the system target (eg. `darwin`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the system system.
  config,
  ...
}: {
  # Enable Snowfall modules
  ${namespace} = {
    # Enable application suites
    suites = {
      # Essential applications for all users
      common.enable = true;

      # Development tools
      development.enable = true;

      # Productivity applications
      productivity.enable = true;

      # Media and entertainment
      media.enable = true;

      # System utilities
      system = {
        enable = true;
        extraCasks = [
          "itsycal"
          "karabiner-elements"
        ];
      };

      # Communication apps
      communication.enable = true;

      # Creative tools (3D printing)
      creative.enable = true;

      # Gaming applications
      gaming.enable = true;
    };

    user = {
      name = "killtw";
      email = "killtw@gmail.com";
      fullName = "Karl Li";
      uid = 501;
      hostname = "m4";
    };
  };
}
