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
      useHead = true;  # 使用 GitHub 最新版本
      autoStart = true;
      disk = 100;
      watchtower.enable = true;
    };
  };

  home.stateVersion = "24.05";
}
