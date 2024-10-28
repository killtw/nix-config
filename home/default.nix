{ username, ... }:

{
  imports = [
    ./core.nix
    ./shell
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
