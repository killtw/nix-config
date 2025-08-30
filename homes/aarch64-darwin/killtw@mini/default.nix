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
      useHead = true;
      autoStart = true;
      disk = 60;
      networkAddress = true;
      networkMode = "bridged";
      dns = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  home.stateVersion = "24.05";
}
