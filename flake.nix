{
  description = "Nix configuration with Snowfall Lib";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    snowfall-lib.url = "github:snowfallorg/lib";

    # System management
    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    # mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Development tools
    devbox.url = "github:jetify-com/devbox";
    opencode.url = "github:anomalyco/opencode";

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

      # Configure NixPkgs channels
      channels-config = {
        # Allow unfree packages
        allowUnfree = true;
      };

      # External modules configuration
      homes.modules = with inputs; [
        # External Home Manager modules can be added here
        # mac-app-util.homeManagerModules.default
      ];

      systems.modules.darwin = with inputs; [
        # mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
}
