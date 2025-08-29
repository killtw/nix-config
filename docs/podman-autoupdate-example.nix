# Podman with Auto-update 配置示例
# 這個檔案展示如何配置 Podman 與自動更新整合

{
  # 基本 Podman 配置
  killtw.programs.cloud.podman = {
    enable = true;
    autoStart = true;  # 開機自動啟動 Podman machine
    
    # 資源配置
    cpu = 4;
    memory = 8;
    disk = 100;
    machineName = "podman-machine-default";
    
    # 啟用相關工具
    enablePodmanDesktop = true;      # 啟用 Podman Desktop GUI
    enableDockerCompose = true;      # 啟用 Docker Compose 相容性
    enablePodmanCompose = true;      # 啟用 podman-compose
    
    # Rootless 模式（推薦）
    rootless = true;
    
    # Auto-update 配置
    autoUpdate = {
      enable = true;                    # 啟用自動更新
      labelEnable = true;               # 只更新有標籤的容器
      schedule = "0 0 4 * * *";         # 每天凌晨 4 點檢查更新
      cleanup = true;                   # 清理舊映像檔
      debug = false;                    # 除錯模式
      
      # 通知設定（可選）
      notifications = {
        enable = false;
        url = "";  # 例如: "slack://token@channel" 或 "smtp://user:pass@host:port/?from=sender&to=recipient"
      };
    };
    
    # 自定義別名
    aliases = {
      pps = "podman ps";
      pimg = "podman images";
      plog = "podman logs";
      pmachine = "podman machine";
    };
  };
}

# 使用方式：
#
# 1. 啟用配置後，Podman machine 會在開機時自動啟動
# 2. Auto-update 會在 Podman machine 啟動後自動運行
# 3. 只有標記了 io.containers.autoupdate=registry 的容器會被自動更新
#
# 容器標籤示例：
# podman run -d --label io.containers.autoupdate=registry nginx
#
# 或在 Containerfile/Dockerfile 中：
# LABEL io.containers.autoupdate=registry
#
# 或在 docker-compose.yml 中（使用 podman-compose）：
# services:
#   web:
#     image: nginx
#     labels:
#       - io.containers.autoupdate=registry
#
# 管理命令：
# - podman-status: 查看 Podman 和容器狀態
# - podman-autoupdate-logs: 查看自動更新日誌
# - podman-autoupdate: 手動觸發更新檢查
# - podman-init: 初始化 Podman machine
#
# Podman 特有功能：
# - Rootless 容器執行（更安全）
# - 原生 systemd 整合（在 Linux 上）
# - 無需 daemon 運行
# - 完整的 Docker API 相容性
#
# 與 Docker Compose 的使用：
# - 使用 podman-compose: podman-compose up -d
# - 或使用 docker-compose（透過 Podman socket）: docker-compose up -d
#
# Kubernetes 支援：
# - podman play kube <yaml-file>  # 執行 Kubernetes YAML
# - podman generate kube <pod>    # 從 pod 生成 Kubernetes YAML
#
# 自動更新標籤說明：
# - io.containers.autoupdate=registry: 從 registry 檢查更新
# - io.containers.autoupdate=local: 從本地檢查更新
# - 沒有標籤或 io.containers.autoupdate=disabled: 不自動更新
#
# 進階配置：
# - 自定義更新排程: schedule = "0 30 2 * * 0";  # 每週日凌晨 2:30
# - 啟用除錯: debug = true;
# - 自定義 machine 名稱: machineName = "my-podman-machine";
#
# 故障排除：
# 1. 檢查 machine 狀態: podman machine list
# 2. 檢查容器狀態: podman ps -a
# 3. 查看自動更新日誌: podman-autoupdate-logs
# 4. 手動觸發更新: podman auto-update --dry-run=false
# 5. 重新初始化 machine: podman machine rm <name> && podman-init
