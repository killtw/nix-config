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

    # Enable colima with auto-start
    programs.cloud.colima = {
      enable = true;
      autoStart = true;
      cpu = 4;
      memory = 8;
      disk = 100;
      runtime = "containerd";  # 維持 containerd runtime
      watchtower.enable = true;  # 啟用容器更新功能（containerd 優化版）
    };

    programs.cloud.podman = {
      enable = true;
      autoStart = true;
      enableDockerCompose = false;
      rootless = false;
    };
  };

  home.stateVersion = "24.05";
}
