# 🏠 Modern Nix Configuration

一個使用 Snowfall Lib 構建的現代化、模組化 Nix 配置系統，提供完整的開發環境配置。

## ✨ 特色

- 🧩 **模組化設計**: 每個工具都是獨立的模組，可選擇性啟用
- 📦 **套件化配置**: 通過 suites 提供預配置的工具組合
- 🎯 **命名空間**: 使用 `killtw` 命名空間避免衝突
- 🔧 **易於擴展**: 標準化的模組結構，易於添加新工具
- 📚 **完整文檔**: 詳細的使用指南和架構說明

## 🚀 快速開始

### 1. 克隆配置
```bash
git clone <this-repo> ~/.config/nix
cd ~/.config/nix
```

### 2. 創建配置文件
```nix
# homes/aarch64-darwin/username@hostname/default.nix
{ config, lib, namespace, ... }:
{
  ${namespace} = {
    suites.common.enable = true;
    user = {
      enable = true;
      name = "your-username";
      fullName = "Your Full Name";
      email = "your.email@example.com";
    };
  };
  home.stateVersion = "24.05";
}
```

### 3. 應用配置
```bash
# 測試構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage

# 應用配置
home-manager switch --flake .#username@hostname
```

## 📦 包含的工具

### 🔧 開發工具 (Development)
- **Git**: 版本控制系統
- **Direnv**: 環境變數管理
- **Kubectl**: Kubernetes 命令行工具
- **Helm**: Kubernetes 套件管理

### 🖥️ 系統工具 (System)
- **Bat**: 現代化 cat 替代品，支援語法高亮
- **Eza**: 現代化 ls 替代品，美觀的文件列表
- **Fzf**: 強大的模糊搜尋工具
- **Starship**: 現代化、快速的 shell prompt
- **Zoxide**: 智能 cd 替代品，記住常用目錄

### 🐚 Shell 配置
- **Zsh**: 功能豐富的 shell，包含插件和自動補全

### 💻 終端工具 (Terminal)
- **Alacritty**: GPU 加速的現代終端模擬器
- **Tmux**: 強大的終端多工器

### ☁️ 雲端工具 (Cloud)
- **AWS CLI**: Amazon Web Services 命令行工具
- **GCP**: Google Cloud Platform 工具
- **Colima**: 輕量級容器運行時

## 🎯 配置方式

### 基礎配置 (推薦)
```nix
${namespace} = {
  suites.common.enable = true;  # 啟用基礎工具套件
  user.enable = true;           # 啟用用戶配置
};
```

### 完整開發環境
```nix
${namespace} = {
  suites = {
    common.enable = true;       # 基礎工具
    development.enable = true;  # 開發工具
  };
  user = {
    enable = true;
    name = "developer";
    fullName = "Developer Name";
    email = "dev@company.com";
  };
};
```

### 自定義配置
```nix
${namespace} = {
  suites.common = {
    enable = true;
    excludeModules = [ "tmux" ];  # 排除特定模組
  };

  # 個別配置工具
  programs = {
    development.git = {
      userName = "Custom Name";
      userEmail = "custom@email.com";
    };
    terminal.alacritty = {
      extraConfig = {
        font.size = 12.0;
        window.opacity = 0.9;
      };
    };
  };
};
```

## 📁 項目結構

```
.
├── 📄 flake.nix                 # Flake 配置
├── 📁 lib/                      # 共用函數庫
│   ├── default.nix             # 主要函數導出
│   └── home.nix                # Home Manager 輔助函數
├── 📁 modules/home/             # Home Manager 模組
│   ├── 👤 user/                # 用戶基礎配置
│   ├── 📦 programs/            # 程式模組
│   │   ├── development/        # 開發工具
│   │   ├── system/             # 系統工具
│   │   ├── shell/              # Shell 配置
│   │   ├── terminal/           # 終端工具
│   │   └── cloud/              # 雲端工具
│   └── 🎁 suites/              # 套件組合
│       ├── common/             # 基礎套件
│       └── development/        # 開發套件
├── 🏠 homes/                   # 用戶配置
│   └── aarch64-darwin/
│       ├── killtw@mini/
│       └── killtw@longshun/
└── 📚 docs/                    # 文檔
    ├── ARCHITECTURE_GUIDE.md   # 架構指南
    ├── USER_GUIDE.md          # 使用指南
    └── QUICK_REFERENCE.md     # 快速參考
```

## 📚 文檔

- 📖 [架構指南](docs/ARCHITECTURE_GUIDE.md) - 詳細的系統架構說明
- 📘 [使用指南](docs/USER_GUIDE.md) - 完整的配置和使用教學
- 📋 [快速參考](docs/QUICK_REFERENCE.md) - 常用命令和配置速查
- 🛠️ [開發指南](docs/development/) - 模組開發和故障排除
- 📊 [項目報告](docs/reports/) - 開發過程和測試報告

## 🛠️ 常用命令

```bash
# 構建配置
nix build .#homeConfigurations.username@hostname.activationPackage

# 應用配置
home-manager switch --flake .#username@hostname

# 測試構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage

# 語法檢查
nix-instantiate --parse path/to/file.nix

# 檢查模組識別
nix eval .#homeModules --apply builtins.attrNames
## 🔧 故障排除

### 常見問題

| 問題 | 解決方案 |
|------|----------|
| 模組未識別 | `git add .` 確保文件被追蹤 |
| 構建失敗 | `nix build --show-trace` 查看詳細錯誤 |
| 語法錯誤 | `nix-instantiate --parse` 檢查語法 |
| 配置不生效 | 重新運行 `home-manager switch` |

### 調試命令
```bash
# 檢查模組識別
nix eval .#homeModules --apply builtins.attrNames

# 檢查配置
nix eval .#homeConfigurations.username@hostname.config

# 顯示詳細錯誤
nix build --show-trace .#homeConfigurations.username@hostname.activationPackage
```

## 🎯 最佳實踐

### ✅ 推薦做法
- 使用 suites 而非個別模組
- 保持配置簡潔明瞭
- 定期測試和備份配置
- 使用版本控制管理變更

### ❌ 避免做法
- 直接修改模組文件
- 忽略語法檢查和測試
- 過度複雜的配置結構

## 🚀 進階用法

### 添加新模組
1. 創建模組目錄和文件
2. 使用標準選項模板
3. 添加到相關 suite
4. 測試和提交變更

### 自定義配置
```nix
# 環境特定配置
${namespace}.programs.development.git = {
  userName = lib.mkIf (config.networking.hostName == "work-laptop") "Work Name";
  userEmail = lib.mkIf (config.networking.hostName == "work-laptop") "work@company.com";
};
```

## 📚 相關資源

### 官方文檔
- [Nix 官方文檔](https://nixos.org/manual/nix/stable/)
- [Home Manager 文檔](https://nix-community.github.io/home-manager/)
- [Snowfall Lib 指南](https://snowfall.org/guides/lib/)

### 社群資源
- [NixOS Discourse](https://discourse.nixos.org/)
- [Nix Community](https://github.com/nix-community)
- [r/NixOS](https://www.reddit.com/r/NixOS/)

## 🙏 致謝

感謝以下項目和貢獻者：

- **[Snowfall Lib](https://snowfall.org/)** - 優秀的 Flake 組織框架
- **[Home Manager](https://github.com/nix-community/home-manager)** - 用戶環境管理
- **Nix 社群** - 持續的貢獻和支援

---

💡 **提示**: 這是一個現代化的 Nix 配置系統，專為提供簡潔、強大、易維護的開發環境而設計。如需詳細說明，請參考相關文檔。
