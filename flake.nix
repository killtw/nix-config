{
  description = "Nix configuration with Snowfall Lib";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    snowfall-lib.url = "github:snowfallorg/lib";

    # System management
    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Development tools
    devbox.url = "github:jetify-com/devbox";

    # Input follows
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # Configure Snowfall Lib
      snowfall = {
        meta = {
          name = "nix-config";
          title = "Karl's Nix Configuration";
        };

        namespace = "killtw";
      };

      # External modules configuration
      homes.modules = with inputs; [
        # External Home Manager modules can be added here
      ];

      systems.modules.darwin = with inputs; [
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
}
