# Nix 配置快速參考

## 🚀 快速開始

### 基礎配置模板
```nix
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
  home.stateVersion = "26.11";
}
```

### 常用命令
```bash
# 構建配置
nix build .#homeConfigurations.username@hostname.activationPackage

# 應用配置
home-manager switch --flake .#username@hostname

# 測試構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage

# 語法檢查
nix-instantiate --parse path/to/file.nix
```

## 📦 可用模組

### Suites 套件
| 套件 | 命名空間 | 包含工具 |
|------|----------|----------|
| Common | `${namespace}.suites.common` | git, direnv, zsh, bat, eza, fzf, zoxide, starship, alacritty, tmux |
| Development | `${namespace}.suites.development` | kubectl, helm, awscli, gcp, colima |

### Development 開發工具
| 工具 | 命名空間 | 描述 |
|------|----------|------|
| Git | `${namespace}.programs.development.git` | 版本控制系統 |
| Direnv | `${namespace}.programs.development.direnv` | 環境變數管理 |
| Kubectl | `${namespace}.programs.development.kubectl` | Kubernetes CLI |
| Helm | `${namespace}.programs.development.helm` | Kubernetes 套件管理 |

### System 系統工具
| 工具 | 命名空間 | 描述 |
|------|----------|------|
| Bat | `${namespace}.programs.system.bat` | 現代化 cat |
| Eza | `${namespace}.programs.system.eza` | 現代化 ls |
| Fzf | `${namespace}.programs.system.fzf` | 模糊搜尋 |
| Starship | `${namespace}.programs.system.starship` | Shell prompt |
| Zoxide | `${namespace}.programs.system.zoxide` | 智能 cd |

### Terminal 終端工具
| 工具 | 命名空間 | 描述 |
|------|----------|------|
| Alacritty | `${namespace}.programs.terminal.alacritty` | GPU 加速終端 |
| Tmux | `${namespace}.programs.terminal.tmux` | 終端多工器 |

### Shell 配置
| 工具 | 命名空間 | 描述 |
|------|----------|------|
| Zsh | `${namespace}.programs.shell.zsh` | Zsh shell 配置 |

### Cloud 雲端工具
| 工具 | 命名空間 | 描述 |
|------|----------|------|
| AWS CLI | `${namespace}.programs.cloud.awscli` | AWS 命令行 |
| GCP | `${namespace}.programs.cloud.gcp` | Google Cloud 工具 |
| Colima | `${namespace}.programs.cloud.colima` | 容器運行時 |

## ⚙️ 配置範例

### 1. 最小配置
```nix
${namespace} = {
  suites.common = {
    enable = true;
    modules = [ "git" "zsh" "bat" "eza" ];
  };
  user.enable = true;
};
```

### 2. 完整開發環境
```nix
${namespace} = {
  suites = {
    common.enable = true;
    development.enable = true;
  };
  user = {
    enable = true;
    name = "developer";
    fullName = "Developer Name";
    email = "dev@company.com";
  };
};
```

### 3. 自定義配置
```nix
${namespace} = {
  suites.common.enable = true;
  
  programs = {
    development.git = {
      userName = "Custom Name";
      userEmail = "custom@email.com";
      aliases = {
        st = "status";
        co = "checkout";
      };
    };
    
    terminal.alacritty = {
      enable = true;
      extraConfig = {
        font.size = 12.0;
        window.opacity = 0.9;
      };
    };
  };
};
```

## 🔧 常用選項

### Suite 選項
```nix
${namespace}.suites.common = {
  enable = true;
  modules = [ "git" "zsh" "alacritty" ];     # 只啟用指定模組
  excludeModules = [ "tmux" ];               # 排除特定模組
};
```

### 基礎模組選項
```nix
${namespace}.programs.category.tool = {
  enable = true;                             # 啟用模組
  package = pkgs.custom-package;             # 自定義套件
  aliases = {                                # Shell 別名
    alias1 = "command1";
    alias2 = "command2";
  };
  extraConfig = {                            # 額外配置
    # 工具特定配置
  };
};
```

### 用戶配置
```nix
${namespace}.user = {
  enable = true;
  name = "username";                         # 用戶名
  fullName = "Full Name";                    # 全名
  email = "email@example.com";               # 電子郵件
};
```

## 🐛 故障排除

### 常見錯誤及解決方案

| 錯誤 | 原因 | 解決方案 |
|------|------|----------|
| `attribute 'programs' missing` | 命名空間錯誤 | 使用 `${namespace}.programs` |
| `module not found` | 文件未被 git 追蹤 | `git add .` |
| `builder failed` | 配置錯誤 | `nix build --show-trace` |
| `syntax error` | Nix 語法錯誤 | `nix-instantiate --parse` |

### 調試命令
```bash
# 檢查模組識別
nix eval .#homeModules --apply builtins.attrNames

# 檢查配置
nix eval .#homeConfigurations.username@hostname.config

# 顯示詳細錯誤
nix build --show-trace .#homeConfigurations.username@hostname.activationPackage

# 檢查語法
nix-instantiate --parse homes/aarch64-darwin/username@hostname/default.nix
```

## 📁 文件結構

```
~/.config/nix/
├── flake.nix                    # 主要 flake 配置
├── lib/                         # 輔助函數
├── modules/home/                # Home Manager 模組
│   ├── user/                   # 用戶配置
│   ├── programs/               # 程式模組
│   │   ├── development/        # 開發工具
│   │   ├── system/             # 系統工具
│   │   ├── shell/              # Shell 配置
│   │   ├── terminal/           # 終端工具
│   │   └── cloud/              # 雲端工具
│   └── suites/                 # 套件組合
└── homes/                      # 用戶配置
    └── aarch64-darwin/
        ├── username@hostname1/
        └── username@hostname2/
```

## 🔄 工作流程

### 1. 修改配置
```bash
# 編輯配置
vim homes/aarch64-darwin/username@hostname/default.nix

# 測試語法
nix-instantiate --parse homes/aarch64-darwin/username@hostname/default.nix

# 測試構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage
```

### 2. 應用配置
```bash
# 應用配置
home-manager switch --flake .#username@hostname

# 或者使用構建結果
nix build .#homeConfigurations.username@hostname.activationPackage
./result/activate
```

### 3. 版本控制
```bash
# 提交變更
git add .
git commit -m "feat: update configuration"
git push
```

## 🎯 最佳實踐

### ✅ 推薦做法
- 使用 suites 而非個別模組
- 保持配置簡潔
- 使用有意義的提交訊息
- 定期測試配置
- 備份重要配置

### ❌ 避免做法
- 直接修改模組文件
- 忽略語法檢查
- 不使用版本控制
- 過度複雜的配置
- 不測試就應用配置

## 📚 相關資源

### 文檔
- [架構指南](ARCHITECTURE_GUIDE.md) - 詳細的架構說明
- [使用指南](USER_GUIDE.md) - 完整的使用教學
- [Nix 官方文檔](https://nixos.org/manual/nix/stable/)
- [Home Manager 文檔](https://nix-community.github.io/home-manager/)

### 工具
- [Snowfall Lib](https://snowfall.org/guides/lib/) - 模組化 Nix 框架
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - 現代 Nix 配置

### 社群
- [NixOS Discourse](https://discourse.nixos.org/)
- [Nix Community](https://github.com/nix-community)
- [r/NixOS](https://www.reddit.com/r/NixOS/)

---

💡 **提示**: 這個快速參考涵蓋了最常用的配置和命令。如需更詳細的說明，請參考完整的使用指南和架構文檔。
