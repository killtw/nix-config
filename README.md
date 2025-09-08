# 🏠 Modern Nix Configuration

一個使用 Snowfall Lib 構建的現代化、模組化 Nix 配置系統，支援 Home Manager 和 Darwin 系統配置。

## ✨ 特色

- 🧩 **模組化設計**: 每個工具都是獨立的模組，可選擇性啟用
- 📦 **套件化配置**: 通過 suites 提供預配置的應用程式組合
- 🍎 **Darwin 支援**: 完整的 macOS 系統級配置和應用程式管理
- 🏠 **Home Manager**: 用戶級環境和工具配置
- 🎯 **命名空間**: 使用 `killtw` 命名空間避免衝突
- 🔧 **易於擴展**: 標準化的模組結構，易於添加新工具
- 📚 **完整文檔**: 詳細的使用指南和架構說明

## 🚀 快速開始

### 1. 克隆配置
```bash
git clone <this-repo> ~/.config/nix
cd ~/.config/nix
```

### 2. Darwin 系統配置 (macOS)
```nix
# systems/aarch64-darwin/hostname/default.nix
{ config, lib, namespace, ... }:
{
  ${namespace} = {
    suites = {
      common.enable = true;      # 基本應用程式
      development.enable = true; # 開發工具
      system.enable = true;      # 系統工具
    };
  };
}
```

### 3. Home Manager 配置
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

### 4. 應用配置
```bash
# Darwin 系統配置
sudo darwin-rebuild switch --flake .#hostname

# Home Manager 配置
home-manager switch --flake .#username@hostname

# 測試構建
nix build --dry-run .#darwinConfigurations.hostname.system
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage
```

## 📦 Darwin Suites - macOS 應用程式管理

Darwin Suites 提供模組化的 macOS 應用程式管理，每個 suite 包含相關的應用程式集合。

### 🏠 Common Suite - 基本應用程式
- **bitwarden-cli**: 密碼管理命令行工具
- **raycast**: 強大的啟動器和生產力工具

### 💻 Development Suite - 開發工具
- **tableplus**: 現代化資料庫管理工具
- **lens**: Kubernetes IDE

### 🖥️ System Suite - 系統工具
- **airbuddy**: AirPods 連接管理
- **betterdisplay**: 顯示器管理工具
- **jordanbaird-ice**: 選單列管理工具
- **popclip**: 剪貼板增強工具
- **surge**: 網路代理工具

### 🎵 Media Suite - 多媒體應用
- **spotify**: 音樂串流服務
- **iina**: 現代化影片播放器
- **sonos**: Sonos 音響系統控制

### 💬 Communication Suite - 通訊應用
- **dingtalk**: 釘釘企業通訊
- **LINE**: LINE 即時通訊

### 🖨️ Printing Suite - 3D 列印工具
- **bambu-studio**: Bambu Lab 3D 列印軟體
- **thumbhost3mf**: 3MF 檔案預覽工具

### 🏢 Office Suite - 辦公應用
- 目前為空，可根據需要添加辦公軟體

### 🎮 Gaming Suite - 遊戲應用
- **steam**: Steam 遊戲平台（透過 extraCasks 配置）

### 🏠 Home Manager 工具

#### 🔧 開發工具 (Development)
- **Git**: 版本控制系統
- **Direnv**: 環境變數管理
- **Kubectl**: Kubernetes 命令行工具
- **Helm**: Kubernetes 套件管理

#### 🖥️ 系統工具 (System)
- **Bat**: 現代化 cat 替代品，支援語法高亮
- **Eza**: 現代化 ls 替代品，美觀的文件列表
- **Fzf**: 強大的模糊搜尋工具
- **Starship**: 現代化、快速的 shell prompt
- **Zoxide**: 智能 cd 替代品，記住常用目錄

#### 🐚 Shell 配置
- **Zsh**: 功能豐富的 shell，包含插件和自動補全

#### 💻 終端工具 (Terminal)
- **Alacritty**: GPU 加速的現代終端模擬器
- **Tmux**: 強大的終端多工器

#### ☁️ 雲端工具 (Cloud)
- **AWS CLI**: Amazon Web Services 命令行工具
- **GCP**: Google Cloud Platform 工具
- **Colima**: 輕量級容器運行時

## 🎯 配置方式

### Darwin 系統配置

#### 基礎配置 (推薦)
```nix
${namespace} = {
  suites = {
    common.enable = true;      # 基本應用程式
    system.enable = true;      # 系統工具
  };
};
```

#### 完整開發環境
```nix
${namespace} = {
  suites = {
    common.enable = true;      # 基本應用程式
    development.enable = true; # 開發工具
    system.enable = true;      # 系統工具
    media.enable = true;       # 多媒體應用
    communication.enable = true; # 通訊應用
  };
};
```

#### 精確控制應用程式
```nix
${namespace} = {
  suites = {
    # 只安裝特定應用程式
    common = {
      enable = true;
      modules = ["raycast"];  # 只安裝 Raycast
    };

    # 排除不需要的應用程式
    system = {
      enable = true;
      excludeModules = ["surge"];  # 排除 Surge
    };

    # 添加額外應用程式
    development = {
      enable = true;
      extraCasks = ["docker"];     # 添加 Docker
      extraMasApps = {
        Xcode = 497799835;         # 添加 Xcode
      };
    };
  };
};
```

### Home Manager 配置

#### 基礎配置
```nix
${namespace} = {
  suites.common.enable = true;  # 啟用基礎工具套件
  user.enable = true;           # 啟用用戶配置
};
```

#### 完整開發環境
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

#### 自定義配置
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
├── 📁 modules/                  # 模組定義
│   ├── 🏠 home/                # Home Manager 模組
│   │   ├── 👤 user/            # 用戶基礎配置
│   │   ├── 📦 programs/        # 程式模組
│   │   │   ├── development/    # 開發工具
│   │   │   ├── system/         # 系統工具
│   │   │   ├── shell/          # Shell 配置
│   │   │   ├── terminal/       # 終端工具
│   │   │   └── cloud/          # 雲端工具
│   │   └── 🎁 suites/          # Home Manager 套件組合
│   │       ├── common/         # 基礎套件
│   │       └── development/    # 開發套件
│   └── 🍎 darwin/              # Darwin 系統模組
│       ├── 📱 apps/            # 應用程式管理
│       └── 🎁 suites/          # Darwin 套件組合
│           ├── common/         # 基本應用程式
│           ├── development/    # 開發工具
│           ├── system/         # 系統工具
│           ├── media/          # 多媒體應用
│           ├── communication/  # 通訊應用
│           ├── printing/       # 3D 列印工具
│           ├── office/         # 辦公應用
│           └── gaming/         # 遊戲應用
├── 🖥️ systems/                 # 系統配置
│   └── aarch64-darwin/
│       └── m4/                 # Darwin 系統配置
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

### Darwin 系統命令
```bash
# 構建 Darwin 配置
nix build .#darwinConfigurations.hostname.system

# 應用 Darwin 配置
sudo darwin-rebuild switch --flake .#hostname

# 測試 Darwin 構建
nix build --dry-run .#darwinConfigurations.hostname.system

# 檢查 Darwin 模組
nix eval .#darwinModules --apply builtins.attrNames
```

### Home Manager 命令
```bash
# 構建 Home Manager 配置
nix build .#homeConfigurations.username@hostname.activationPackage

# 應用 Home Manager 配置
home-manager switch --flake .#username@hostname

# 測試 Home Manager 構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage

# 檢查 Home Manager 模組
nix eval .#homeModules --apply builtins.attrNames
```

### 通用命令
```bash
# 語法檢查
nix-instantiate --parse path/to/file.nix

# 顯示詳細錯誤
nix build --show-trace .#target

# 清理舊版本
nix-collect-garbage -d
```

## 🍎 Darwin Suites 詳細說明

### 架構設計

Darwin Suites 採用模組化設計，每個 suite 都是獨立的 NixOS 模組，直接管理 Homebrew 和系統包配置。這種設計具有以下優勢：

- **簡潔性**: 每個 suite 直接配置應用程式，無複雜的抽象層
- **靈活性**: 可以精確控制每個應用程式的安裝
- **兼容性**: 與現有的 apps 模組並存，不會產生衝突
- **可擴展性**: 易於添加新的 suite 和應用程式

### 應用程式類型

Darwin Suites 支援多種應用程式安裝方式：

- **Homebrew Casks**: GUI 應用程式 (如 `arc`, `raycast`)
- **Homebrew Brews**: 命令行工具 (如 `bitwarden-cli`)
- **Mac App Store**: App Store 應用程式 (如 `Keynote`, `LINE`)
- **Nix Packages**: 系統包 (如 `git`, `wget`)

### 配置選項

每個 suite 都支援以下配置選項：

```nix
suites.suiteName = {
  enable = true;                    # 啟用 suite
  modules = ["app1" "app2"];        # 指定要安裝的應用程式
  excludeModules = ["app3"];        # 排除特定應用程式
  extraTaps = ["tap/name"];         # 額外的 Homebrew taps
  extraBrews = ["brew-name"];       # 額外的 Homebrew brews
  extraCasks = ["cask-name"];       # 額外的 Homebrew casks
  extraMasApps = {                  # 額外的 Mac App Store 應用程式
    "App Name" = 123456789;
  };
  extraPackages = [ pkgs.package ]; # 額外的 Nix packages
};
```

### 實際使用範例

```nix
# 完整的 Darwin 配置範例
${namespace} = {
  suites = {
    # 基本應用程式 - 只安裝 Raycast
    common = {
      enable = true;
      modules = ["raycast"];
    };

    # 開發工具 - 排除 Lens，添加 Docker
    development = {
      enable = true;
      excludeModules = ["lens"];
      extraCasks = ["docker"];
    };

    # 系統工具 - 添加額外的系統工具
    system = {
      enable = true;
      extraCasks = ["itsycal" "karabiner-elements"];
    };

    # 多媒體 - 只安裝 Spotify 和 IINA
    media = {
      enable = true;
      modules = ["spotify" "iina"];
    };
  };
};
```

### 與 Apps 模組的關係

Darwin Suites 與現有的 `apps` 模組是互補的：

- **Suites**: 提供預配置的應用程式組合，適合快速設置
- **Apps**: 提供細粒度的應用程式管理，適合自定義配置

兩者可以同時使用，配置會自動合併。

## 🔧 故障排除

### 常見問題

| 問題 | 解決方案 |
|------|----------|
| 模組未識別 | `git add .` 確保文件被追蹤 |
| 構建失敗 | `nix build --show-trace` 查看詳細錯誤 |
| 語法錯誤 | `nix-instantiate --parse` 檢查語法 |
| Darwin 配置不生效 | 重新運行 `sudo darwin-rebuild switch --flake .#hostname` |
| Home Manager 配置不生效 | 重新運行 `home-manager switch --flake .#username@hostname` |
| Homebrew 應用程式未安裝 | 檢查 Homebrew 是否正確安裝和配置 |

### 調試命令

#### Darwin 系統調試
```bash
# 檢查 Darwin 模組識別
nix eval .#darwinModules --apply builtins.attrNames

# 檢查 Darwin 配置
nix eval .#darwinConfigurations.hostname.config.homebrew

# 檢查 suite 選項
nix eval .#darwinConfigurations.hostname.options.killtw.suites --apply builtins.attrNames

# 顯示詳細錯誤
nix build --show-trace .#darwinConfigurations.hostname.system
```

#### Home Manager 調試
```bash
# 檢查 Home Manager 模組識別
nix eval .#homeModules --apply builtins.attrNames

# 檢查 Home Manager 配置
nix eval .#homeConfigurations.username@hostname.config

# 顯示詳細錯誤
nix build --show-trace .#homeConfigurations.username@hostname.activationPackage
```

## 🎯 最佳實踐

### ✅ 推薦做法

#### Darwin 系統配置
- 優先使用 Darwin suites 進行應用程式管理
- 使用 `modules` 和 `excludeModules` 精確控制應用程式
- 將系統級配置與用戶級配置分離
- 定期測試 Darwin 配置的構建和部署

#### Home Manager 配置
- 使用 Home Manager suites 管理開發工具
- 保持用戶配置的可移植性
- 避免在 Home Manager 中配置系統級設置

#### 通用建議
- 保持配置簡潔明瞭
- 定期測試和備份配置
- 使用版本控制管理變更
- 在修改前先測試構建 (`nix build --dry-run`)

### ❌ 避免做法
- 直接修改模組文件
- 忽略語法檢查和測試
- 過度複雜的配置結構
- 在 Home Manager 中配置系統級應用程式
- 混合使用 Darwin suites 和手動 Homebrew 管理

## 🚀 進階用法

### 添加新的 Darwin Suite
1. 創建新的 suite 目錄：`modules/darwin/suites/newsuite/`
2. 創建 `default.nix` 文件，使用標準模板：
```nix
{ lib, pkgs, config, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.newsuite;
  availableModules = [
    "app1"
    "app2"
  ];
in
{
  options.${namespace}.suites.newsuite = mkDarwinSuiteOptions "newsuite" availableModules;

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [] ++ (if elem "app1" (subtractLists cfg.excludeModules cfg.modules) then [
        "app1"
      ] else []) ++ cfg.extraCasks;
    };
  };
}
```
3. 測試和提交變更

### 環境特定配置
```nix
# 根據主機名稱使用不同配置
${namespace}.suites = lib.mkMerge [
  # 基本配置
  {
    common.enable = true;
    system.enable = true;
  }

  # 工作環境特定配置
  (lib.mkIf (config.networking.hostName == "work-mac") {
    development.enable = true;
    communication.enable = true;
  })

  # 個人環境特定配置
  (lib.mkIf (config.networking.hostName == "personal-mac") {
    media.enable = true;
    gaming.enable = true;
  })
];
```

### 條件式應用程式安裝
```nix
${namespace}.suites.development = {
  enable = true;
  # 根據條件排除應用程式
  excludeModules = lib.optionals (!config.services.docker.enable) ["lens"];
  # 根據條件添加應用程式
  extraCasks = lib.optionals (config.networking.hostName == "dev-machine") ["docker"];
};
```

## 📚 相關資源

### 官方文檔
- [Nix 官方文檔](https://nixos.org/manual/nix/stable/)
- [Home Manager 文檔](https://nix-community.github.io/home-manager/)
- [nix-darwin 文檔](https://github.com/LnL7/nix-darwin)
- [Snowfall Lib 指南](https://snowfall.org/guides/lib/)
- [Homebrew 官方網站](https://brew.sh/)

### 社群資源
- [NixOS Discourse](https://discourse.nixos.org/)
- [Nix Community](https://github.com/nix-community)
- [nix-darwin Issues](https://github.com/LnL7/nix-darwin/issues)
- [r/NixOS](https://www.reddit.com/r/NixOS/)

### 實用工具
- [Homebrew Formulae](https://formulae.brew.sh/) - 搜尋 Homebrew 套件
- [Mac App Store Connect](https://appstoreconnect.apple.com/) - 查找 App Store ID

## 🙏 致謝

感謝以下項目和貢獻者：

- **[Snowfall Lib](https://snowfall.org/)** - 優秀的 Flake 組織框架
- **[Home Manager](https://github.com/nix-community/home-manager)** - 用戶環境管理
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** - macOS 系統配置管理
- **[Homebrew](https://brew.sh/)** - macOS 套件管理器
- **Nix 社群** - 持續的貢獻和支援

---

💡 **提示**: 這是一個現代化的 Nix 配置系統，支援 macOS 系統級和用戶級配置管理，專為提供簡潔、強大、易維護的開發環境而設計。Darwin Suites 讓 macOS 應用程式管理變得更加直觀和靈活。
