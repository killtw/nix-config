{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self, nixpkgs, darwin, home-manager, devenv, nix-homebrew, systems, ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    pkgs = import nixpkgs { system = "aarch64-darwin"; };
    darwinSystem = {username ? "killtw", hostname, system ? "aarch64-darwin"}:
      darwin.lib.darwinSystem {
        system = system;
        inherit pkgs;
        specialArgs = { inherit inputs hostname username; };

        modules = [
          ./modules/core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/users.nix
          nix-homebrew.darwinModules.nix-homebrew (import ./modules/homebrew.nix)
          home-manager.darwinModules.home-manager (import ./modules/home-manager.nix)
        ];
      };
  in
  {
    darwinConfigurations = rec {
      "mini" = darwinSystem {
        hostname = "mini";
      };
    };

    packages = forEachSystem(system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });

    devShells = forEachSystem(system: let
      pkgs = import nixpkgs { system = system; };
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [];
      };
    });

  };
}
