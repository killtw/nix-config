# Colima with Watchtower 配置示例
# 這個檔案展示如何配置 Colima 與 Watchtower 整合

{
  # 基本 Colima 配置
  killtw.programs.cloud.colima = {
    enable = true;
    autoStart = true;  # 開機自動啟動 Colima
    
    # 資源配置
    cpu = 4;
    memory = 8;
    disk = 100;
    runtime = "docker";
    
    # 啟用 Docker 相關工具
    enableDocker = true;
    enableDockerCompose = true;
    
    # Watchtower 配置
    watchtower = {
      enable = true;                    # 啟用 Watchtower
      labelEnable = true;               # 只更新有標籤的容器
      schedule = "0 0 4 * * *";         # 每天凌晨 4 點檢查更新
      cleanup = true;                   # 清理舊映像檔
      debug = false;                    # 除錯模式
      includeRestarting = false;        # 不包含重啟中的容器
      includeStoppedContainers = false; # 不包含已停止的容器
      
      # 通知設定（可選）
      notifications = {
        enable = false;
        url = "";  # 例如: "slack://token@channel" 或 "smtp://user:pass@host:port/?from=sender&to=recipient"
      };
    };
    
    # 自定義別名
    aliases = {
      dps = "docker ps";
      dimg = "docker images";
      dlog = "docker logs";
    };
  };
}

# 使用方式：
#
# 1. 啟用配置後，Colima 會在開機時自動啟動
# 2. Watchtower 會在 Colima 啟動後自動運行
# 3. 只有標記了 com.centurylinklabs.watchtower.enable=true 的容器會被自動更新
#
# 容器標籤示例：
# docker run -d --label com.centurylinklabs.watchtower.enable=true nginx
#
# 或在 docker-compose.yml 中：
# services:
#   web:
#     image: nginx
#     labels:
#       - com.centurylinklabs.watchtower.enable=true
#
# 管理命令：
# - watchtower-status: 查看 Watchtower 狀態
# - watchtower-logs: 查看 Watchtower 日誌
# - watchtower-restart: 重啟 Watchtower 容器
