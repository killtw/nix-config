{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devbox.url = "github:jetify-com/devbox";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";

    # follows
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self, nixpkgs, darwin, home-manager, nix-homebrew, ...
  }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { system = system; };
    darwinSystem = {username ? "killtw", hostname, arch ? system}:
      darwin.lib.darwinSystem {
        system = arch;
        inherit pkgs;
        specialArgs = { inherit inputs hostname username; };

        modules = [
          ./modules/apps.nix
          ./modules/core.nix
          ./modules/system.nix
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
      "longshun" = darwinSystem {
        hostname = "longshun";
      };
    };
  };
}
