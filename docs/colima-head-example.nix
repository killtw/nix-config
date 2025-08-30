# Colima HEAD 版本配置範例
# 這個檔案展示如何使用 Colima 的最新開發版本

{
  # 使用 Colima HEAD 版本（從 GitHub 最新源碼構建）
  killtw.programs.cloud.colima = {
    enable = true;
    
    # 啟用 HEAD 版本 - 從 GitHub main 分支構建
    useHead = true;
    
    # 基本配置
    autoStart = true;  # 開機自動啟動
    
    # 資源配置
    cpu = 4;      # CPU 核心數
    memory = 8;   # 記憶體 GB
    disk = 100;   # 磁碟空間 GB
    
    # 容器運行時
    runtime = "docker";  # 或 "containerd"
    
    # 功能啟用
    enableDocker = true;           # 啟用 Docker CLI
    enableDockerCompose = true;    # 啟用 Docker Compose
    
    # Watchtower 自動更新配置
    watchtower = {
      enable = true;               # 啟用 Watchtower
      labelEnable = true;          # 只更新有標籤的容器
      schedule = "0 0 4 * * *";    # 每天凌晨 4 點執行
      cleanup = true;              # 更新後清理舊映像
      
      # 通知配置（可選）
      notifications = {
        enable = false;            # 啟用通知
        url = "";                  # Slack webhook 或 email SMTP URL
      };
      
      includeRestarting = false;   # 包含重啟中的容器
      includeStoppedContainers = false;  # 包含已停止的容器
      debug = false;               # 啟用除錯日誌
    };
    
    # 自定義別名
    aliases = {
      dps = "docker ps";
      dimg = "docker images";
      dlog = "docker logs";
      colima-st = "colima status";
      colima-ssh = "colima ssh";
    };
  };
}

# 使用方式：
#
# 1. 啟用配置後，系統會從 GitHub 最新源碼構建 Colima
# 2. 獲得最新的功能和修復，但可能不如穩定版本穩定
# 3. 提供完整的 Docker API 相容性
# 4. 支援所有標準的 Docker 和 Docker Compose 命令
#
# HEAD 版本的優勢：
# - 最新功能和改進
# - 最新的錯誤修復
# - 支援最新的 macOS 版本
# - 性能優化和改進
#
# HEAD 版本的注意事項：
# - 可能包含未完全測試的功能
# - 可能有穩定性問題
# - 構建時間較長（需要從源碼編譯）
# - 需要定期更新 SHA256 hash
#
# 管理命令：
# - colima start: 啟動 Colima
# - colima stop: 停止 Colima
# - colima status: 查看狀態
# - colima ssh: SSH 進入 VM
# - colima delete: 刪除 VM
# - colima list: 列出所有實例
#
# Watchtower 功能：
# - 自動監控和更新容器
# - 支援 cron 排程
# - 可配置通知
# - 支援標籤過濾
# - 自動清理舊映像
#
# 更新 HEAD 版本：
# 1. 獲取最新的 commit hash:
#    nix-shell -p nix-prefetch-github --run "nix-prefetch-github abiosoft colima --rev main"
# 2. 更新模組中的 rev 和 sha256
# 3. 重新構建配置
#
# 故障排除：
# - 如果構建失敗，檢查是否有編譯錯誤
# - 確認系統有足夠的資源進行編譯
# - 檢查網路連接是否正常
# - 查看構建日誌以獲取詳細錯誤資訊
#
# 與穩定版本的比較：
# - HEAD 版本：最新功能，可能不穩定，需要編譯
# - 穩定版本：經過測試，穩定可靠，預編譯二進制
#
# 建議使用場景：
# - 需要最新功能的開發者
# - 願意承擔穩定性風險的用戶
# - 需要特定修復的用戶
# - 貢獻代碼的開發者
#
# 不建議使用場景：
# - 生產環境
# - 穩定性要求高的場景
# - 網路頻寬有限的環境
# - 編譯資源有限的系統
