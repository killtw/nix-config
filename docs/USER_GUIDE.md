# Nix 配置使用指南

## 快速開始

### 1. 基礎配置

最簡單的配置方式是使用 suites：

```nix
# homes/aarch64-darwin/username@hostname/default.nix
{ config, lib, namespace, ... }:

{
  ${namespace} = {
    # 啟用基礎套件
    suites.common.enable = true;
    
    # 配置用戶資訊
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

### 2. 進階配置

如果需要開發工具，可以添加 development suite：

```nix
{ config, lib, namespace, ... }:

{
  ${namespace} = {
    suites = {
      common.enable = true;
      development.enable = true;
    };
    
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

## 配置選項

### Suites 套件

#### Common Suite
**包含工具**:
- **開發基礎**: git, direnv
- **現代化 shell**: zsh
- **系統工具**: bat, eza, fzf, zoxide, starship
- **終端工具**: alacritty, tmux

**啟用方式**:
```nix
${namespace}.suites.common.enable = true;
```

#### Development Suite
**包含工具**:
- **Kubernetes**: kubectl, helm
- **雲端工具**: awscli, gcp, colima

**啟用方式**:
```nix
${namespace}.suites.development.enable = true;
```

#### 選擇性模組啟用
```nix
${namespace}.suites.common = {
  enable = true;
  modules = [ "git" "zsh" "alacritty" ];  # 只啟用指定模組
};

# 或者排除特定模組
${namespace}.suites.common = {
  enable = true;
  excludeModules = [ "tmux" ];  # 排除 tmux
};
```

### 個別模組配置

#### 用戶配置
```nix
${namespace}.user = {
  enable = true;
  name = "killtw";
  fullName = "Karl Li";
  email = "killtw@gmail.com";
};
```

#### Git 配置
```nix
${namespace}.programs.development.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  aliases = {
    st = "status";
    co = "checkout";
    br = "branch";
  };
};
```

#### Zsh 配置
```nix
${namespace}.programs.shell.zsh = {
  enable = true;
  aliases = {
    ll = "ls -la";
    la = "ls -A";
    l = "ls -CF";
  };
  extraConfig = {
    # 額外的 zsh 配置
  };
};
```

#### Alacritty 配置
```nix
${namespace}.programs.terminal.alacritty = {
  enable = true;
  extraConfig = {
    # 覆蓋預設配置
    font.size = 12.0;
    window.opacity = 0.9;
  };
};
```

#### Tmux 配置
```nix
${namespace}.programs.terminal.tmux = {
  enable = true;
  extraConfig = {
    # 額外的 tmux 配置
  };
};
```

## 常用配置範例

### 1. 最小配置
適合只需要基礎工具的用戶：

```nix
{ config, lib, namespace, ... }:

{
  ${namespace} = {
    suites.common = {
      enable = true;
      modules = [ "git" "zsh" "bat" "eza" "fzf" ];
    };
    
    user.enable = true;
  };

  home.stateVersion = "24.05";
}
```

### 2. 開發者配置
適合需要完整開發環境的用戶：

```nix
{ config, lib, namespace, ... }:

{
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
    
    # 自定義 git 配置
    programs.development.git = {
      userName = "Developer Name";
      userEmail = "dev@company.com";
      aliases = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit -m";
        ps = "push";
        pl = "pull";
      };
    };
  };

  home.stateVersion = "24.05";
}
```

### 3. 自定義配置
適合有特殊需求的用戶：

```nix
{ config, lib, namespace, ... }:

{
  ${namespace} = {
    # 基礎套件但排除 tmux
    suites.common = {
      enable = true;
      excludeModules = [ "tmux" ];
    };
    
    user.enable = true;
    
    # 只啟用特定的開發工具
    programs = {
      development = {
        kubectl.enable = true;
        helm.enable = true;
      };
      
      cloud = {
        awscli.enable = true;
      };
      
      # 自定義 alacritty
      terminal.alacritty = {
        enable = true;
        extraConfig = {
          font = {
            size = 13.0;
            normal.family = "JetBrains Mono";
          };
          window = {
            opacity = 0.95;
            padding = { x = 20; y = 18; };
          };
        };
      };
    };
  };

  home.stateVersion = "24.05";
}
```

## 部署和管理

### 1. 初次部署

```bash
# 克隆配置
git clone <your-config-repo> ~/.config/nix
cd ~/.config/nix

# 構建配置
nix build .#homeConfigurations.username@hostname.activationPackage

# 啟用配置
./result/activate
```

### 2. 更新配置

```bash
# 修改配置文件
vim homes/aarch64-darwin/username@hostname/default.nix

# 測試配置
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage

# 應用配置
home-manager switch --flake .#username@hostname
```

### 3. 回滾配置

```bash
# 查看歷史
home-manager generations

# 回滾到特定版本
home-manager switch --flake .#username@hostname --generation <number>
```

## 故障排除

### 常見問題

#### 1. 模組未找到
```
error: attribute 'programs' missing
```

**解決方案**:
- 確保使用正確的命名空間 `${namespace}`
- 檢查模組路徑是否正確

#### 2. 構建失敗
```
error: builder for '/nix/store/...' failed
```

**解決方案**:
```bash
# 顯示詳細錯誤
nix build --show-trace .#homeConfigurations.username@hostname.activationPackage

# 檢查語法
nix-instantiate --parse homes/aarch64-darwin/username@hostname/default.nix
```

#### 3. 配置不生效
**解決方案**:
- 確保運行了 `home-manager switch`
- 檢查 shell 環境變數是否正確載入
- 重新啟動終端或重新登入

### 調試技巧

#### 1. 檢查配置
```bash
# 查看最終配置
nix eval .#homeConfigurations.username@hostname.config.programs

# 查看特定模組配置
nix eval .#homeConfigurations.username@hostname.config.killtw.programs.development.git
```

#### 2. 測試模組
```bash
# 測試單個模組語法
nix-instantiate --parse modules/home/programs/development/git/default.nix

# 測試配置構建
nix build --dry-run .#homeConfigurations.username@hostname.activationPackage
```

#### 3. 查看日誌
```bash
# Home Manager 日誌
journalctl --user -u home-manager-username@hostname.service

# 查看啟用腳本
cat ~/.local/state/home-manager/gcroots/current-home/activate
```

## 最佳實踐

### 1. 配置管理
- 使用 git 管理配置變更
- 定期備份配置
- 使用有意義的提交訊息

### 2. 模組選擇
- 優先使用 suites 而非個別模組
- 只啟用需要的工具
- 定期檢查和清理不需要的模組

### 3. 自定義配置
- 使用 `extraConfig` 進行細微調整
- 避免直接修改模組文件
- 保持配置簡潔明瞭

### 4. 測試流程
- 修改前先備份當前配置
- 使用 `--dry-run` 測試構建
- 逐步應用變更

## 進階用法

### 1. 條件配置
```nix
${namespace} = {
  suites.common.enable = true;
  
  # 根據主機名條件啟用
  programs.development.kubectl.enable = 
    builtins.elem config.networking.hostName [ "work-laptop" "dev-server" ];
};
```

### 2. 環境特定配置
```nix
# 工作環境
${namespace}.programs.development.git = {
  userName = "Work Name";
  userEmail = "work@company.com";
};

# 個人環境
${namespace}.programs.development.git = {
  userName = "Personal Name";
  userEmail = "personal@email.com";
};
```

### 3. 共享配置
```nix
# 創建共享配置文件
# shared/common.nix
{ namespace, ... }: {
  ${namespace} = {
    suites.common.enable = true;
    user.enable = true;
  };
}

# 在主配置中導入
{ config, lib, namespace, ... }:

{
  imports = [ ../../../shared/common.nix ];
  
  # 主機特定配置
  ${namespace}.user = {
    name = "specific-user";
    fullName = "Specific User";
    email = "specific@email.com";
  };
}
```

這個使用指南提供了從基礎到進階的完整配置方法，幫助用戶快速上手並充分利用這個 Nix 配置系統。
