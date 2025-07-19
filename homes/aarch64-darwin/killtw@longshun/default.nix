{ config, lib, ... }:

{
  programs = {
    shell-config.enable = true;
    git-config.enable = true;
    terminal-config.enable = true;
    user-config.enable = true;
  };

  home.stateVersion = "24.05";
}
