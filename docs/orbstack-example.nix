# OrbStack 配置示例
# 這個檔案展示如何配置 OrbStack 容器運行環境

{
  # 基本 OrbStack 配置
  killtw.programs.cloud.orbstack = {
    enable = true;
    autoStart = true;  # 開機自動啟動 OrbStack

    # 安裝方式配置（僅影響 CLI 路徑檢測）
    installMethod = "homebrew";    # 安裝方式：homebrew 或 manual

    # 資源配置提示（OrbStack 會自動管理，這些是建議值）
    cpu = 4;      # CPU 核心數提示（0 = 自動）
    memory = 8;   # 記憶體 GB 提示（0 = 自動）
    disk = 100;   # 磁碟空間 GB 提示（0 = 自動）

    # 功能啟用
    enableDocker = true;           # 啟用 Docker 相容性
    enableDockerCompose = true;    # 啟用 Docker Compose
    enableKubernetes = false;      # 啟用 Kubernetes 支援

    # Docker socket 配置
    dockerSocket = "/var/run/docker.sock";  # Docker socket 路徑

    # 自定義別名
    aliases = {
      dps = "docker ps";
      dimg = "docker images";
      dlog = "docker logs";
      orb-st = "orbstack-status";
      orb-mg = "orbstack-manage";
    };
  };
}

# 使用方式：
#
# 1. 安裝 OrbStack（聲明式管理）：
#    在您的 systems/<arch>/<hostname>/default.nix 中添加：
#    killtw.apps = {
#      extraCasks = [ "orbstack" ];
#      extraBrews = [ "orbstack" ];
#    };
#    然後執行: sudo nix run nix-darwin -- switch --flake ~/.config/nix
#
# 2. 啟用配置後，OrbStack 會在開機時自動啟動
# 3. 提供完整的 Docker API 相容性
# 4. 支援所有標準的 Docker 和 Docker Compose 命令
#
# 管理命令：
# - orbstack-status: 查看 OrbStack 和容器狀態
# - orbstack-logs: 查看 OrbStack 日誌
# - orbstack-manage: 管理 OrbStack（start/stop/restart/reset/update）
# - orb-init: 初始化 OrbStack 配置
#
# OrbStack 特色功能：
# - 原生 macOS 整合，無需 VM
# - 極快的啟動速度和檔案系統性能
# - 自動資源管理，無需手動配置
# - 內建 Kubernetes 支援
# - 完整的 Docker API 相容性
# - 支援 Linux 發行版容器
#
# 與 Docker Desktop 的使用：
# - 完全相容的 Docker API
# - 使用相同的 docker 和 docker-compose 命令
# - 支援現有的 Dockerfile 和 docker-compose.yml
#
# 與其他容器運行環境的比較：
# - 比 Docker Desktop 更輕量和快速
# - 比 colima 更簡單，無需複雜配置
# - 比 podman 更接近 Docker 體驗
# - 原生 macOS 整合，無需虛擬化開銷
#
# 進階配置：
# - 自動啟動: autoStart = true;
# - Kubernetes: enableKubernetes = true;
# - 資源提示: cpu = 8; memory = 16; disk = 200;
#
# 故障排除：
# 1. 檢查 OrbStack 狀態: orbstack-status
# 2. 查看日誌: orbstack-logs
# 3. 重新啟動: orbstack-manage restart
# 4. 重置（清除所有資料）: orbstack-manage reset
# 5. 更新: orbstack-manage update
#
# 注意事項：
# - OrbStack 需要 macOS 12.0 或更新版本
# - 首次使用需要從 App Store 或官網安裝 OrbStack 應用程式
# - 資源配置為提示值，OrbStack 會根據系統狀況自動調整
# - 與其他容器運行環境（Docker Desktop、colima、podman）可能會有衝突
#
# 推薦使用場景：
# - 需要最佳 macOS 整合體驗
# - 重視啟動速度和性能
# - 希望簡化容器環境管理
# - 需要同時使用 Docker 和 Linux 環境
# - 開發需要快速容器啟動的應用程式
