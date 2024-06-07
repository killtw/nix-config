{ machineConfig, ... }:

{
  imports = [
    ./core.nix
    ./shell
  ];

  home = {
    username = machineConfig.username;
    homeDirectory = "/Users/${machineConfig.username}";

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
