# OrbStack 系統配置範例
# 這個檔案展示如何在系統層級聲明式地安裝 OrbStack

# systems/aarch64-darwin/your-hostname/default.nix
{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}: {
  # 啟用 Snowfall 模組
  ${namespace} = {
    # 應用程式配置 - 聲明式安裝 OrbStack
    apps = {
      # 基本應用程式啟用
      enable = true;
      
      # 添加 OrbStack 相關的 Homebrew 套件
      extraCasks = [
        "orbstack"  # OrbStack 應用程式（GUI）
        
        # 其他您需要的應用程式
        # "docker"  # 如果您不使用 OrbStack，可以安裝 Docker Desktop
        # "postman"
        # "visual-studio-code"
      ];
      
      extraBrews = [
        "orbstack"  # OrbStack CLI 工具
        
        # 其他您需要的命令列工具
        # "htop"
        # "tree"
        # "jq"
      ];
      
      # 可選：Mac App Store 應用程式
      extraMasApps = {
        # "Xcode" = 497799835;
        # "TestFlight" = 899247664;
      };
    };

    # 用戶配置
    user = {
      name = "your-username";
      email = "your.email@example.com";
      fullName = "Your Full Name";
      uid = 501;
      hostname = "your-hostname";
    };
  };
}

# 使用方式：
#
# 1. 將此配置添加到您的系統配置檔案中
# 2. 執行: sudo nix run nix-darwin -- switch --flake ~/.config/nix
# 3. OrbStack 將會透過 Homebrew 自動安裝
# 4. 在您的 home-manager 配置中啟用 OrbStack 模組：
#
#    killtw.programs.cloud.orbstack = {
#      enable = true;
#      autoStart = true;
#      installMethod = "homebrew";  # 告訴模組 CLI 是透過 Homebrew 安裝的
#    };
#
# 5. 執行 home-manager 配置更新
#
# 優勢：
# - 完全聲明式管理，符合 Nix 理念
# - 版本控制和可重現性
# - 自動依賴管理
# - 可以輕鬆在多台機器間同步配置
# - 支援回滾和版本管理
#
# 注意事項：
# - OrbStack 需要 macOS 12.0 或更新版本
# - 首次安裝後可能需要手動啟動 OrbStack 應用程式進行初始設定
# - 確保您的系統有足夠的權限執行 Homebrew 安裝
#
# 故障排除：
# - 如果安裝失敗，檢查 Homebrew 是否正確安裝
# - 確認您的用戶有管理員權限
# - 檢查網路連接是否正常
# - 查看 nix-darwin 的輸出日誌以獲取詳細錯誤資訊
#
# 與其他容器運行環境的整合：
# - 如果您同時使用多個容器運行環境，請確保只啟用其中一個
# - 建議在不同的系統配置中使用不同的容器運行環境
# - 可以透過 excludeModules 來停用不需要的模組：
#
#    killtw.suites.development = {
#      enable = true;
#      modules = ["orbstack"];
#      excludeModules = ["colima", "podman"];
#    };
