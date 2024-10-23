{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    self, nixpkgs, darwin, home-manager, devenv, nix-homebrew, ...
  }: let
    machineConfig = {
      system = "aarch64-darwin";
      hostname = "KKday";
      username = "killtw";
    };
    pkgs = import nixpkgs { system = machineConfig.system; };
  in
  {
    darwinConfigurations = rec {
      ${machineConfig.hostname} = darwin.lib.darwinSystem {
        system = machineConfig.system;
        inherit pkgs;
        specialArgs = { inherit inputs machineConfig; };

        modules = [
          ./modules/core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/users.nix
          nix-homebrew.darwinModules.nix-homebrew (import ./modules/homebrew.nix)
          home-manager.darwinModules.home-manager (import ./modules/home-manager.nix)
        ];
      };
    };

    packages.${machineConfig.system}.devenv-up = self.devShells.${machineConfig.system}.default.config.procfileScript;

    devShells.${machineConfig.system}.default = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [];
    };

  };
}
