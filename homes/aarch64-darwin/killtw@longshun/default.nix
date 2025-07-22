{ config, lib, namespace, ... }:

{
  killtw = {
    suites = {
      common.enable = true;
    };

    user = {
      enable = true;
      name = "killtw";
      fullName = "Karl Li";
      email = "killtw@gmail.com";
    };
  };

  home.stateVersion = "24.05";
}
