{ config, lib, namespace, ... }:

{
  killtw = {
    suites = {
      common.enable = true;
      development.enable = true;
    };

    user = {
      enable = true;
      name = "killtw";
      fullName = "Karl Li";
      email = "killtw@gmail.com";
    };

    programs.cloud.colima = {
      enable = true;
      autoStart = true;
      disk = 100;
      watchtower.enable = true;
    };

    programs.cloud.orbstack = {
      enable = true;
      autoStart = true;
    };
  };

  home.stateVersion = "24.05";
}
