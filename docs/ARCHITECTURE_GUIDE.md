# Nix 配置架構指南

## 概述

本項目使用 Snowfall Lib 構建的現代化 Nix 配置系統，提供模組化、可擴展的開發環境配置。

## 架構設計

### 核心理念

1. **模組化**: 每個工具都是獨立的模組
2. **命名空間**: 使用 `killtw` 命名空間避免衝突
3. **套件化**: 通過 suites 提供預配置的工具組合
4. **可組合**: 用戶可以選擇性啟用或排除模組

### 目錄結構

```
.
├── flake.nix                    # Flake 配置
├── lib/                         # 共用函數庫
│   ├── default.nix             # 主要函數導出
│   └── home.nix                # Home Manager 輔助函數
├── modules/
│   ├── home/                   # Home Manager 模組
│   │   ├── user/               # 用戶基礎配置
│   │   ├── programs/           # 程式模組
│   │   │   ├── development/    # 開發工具
│   │   │   ├── system/         # 系統工具
│   │   │   ├── shell/          # Shell 配置
│   │   │   ├── terminal/       # 終端工具
│   │   │   └── cloud/          # 雲端工具
│   │   └── suites/             # 套件組合
│   │       ├── common/         # 基礎套件
│   │       └── development/    # 開發套件
│   └── darwin/                 # macOS 系統模組
└── homes/                      # 用戶配置
    └── aarch64-darwin/
        ├── killtw@mini/
        └── killtw@longshun/
```

## 模組架構

### 1. 用戶模組 (User)

**路徑**: `modules/home/user/`
**命名空間**: `killtw.user`

提供基礎用戶配置：
- 用戶名和全名
- 電子郵件
- Home 目錄設定
- Home Manager 啟用

### 2. 程式模組 (Programs)

#### Development 開發工具
**路徑**: `modules/home/programs/development/`
**命名空間**: `killtw.programs.development`

- **git**: 版本控制系統
- **direnv**: 環境變數管理
- **helm**: Kubernetes 套件管理
- **kubectl**: Kubernetes 命令行工具

#### System 系統工具
**路徑**: `modules/home/programs/system/`
**命名空間**: `killtw.programs.system`

- **bat**: 現代化 cat 替代品
- **eza**: 現代化 ls 替代品
- **fzf**: 模糊搜尋工具
- **starship**: 現代化 shell prompt
- **zoxide**: 智能 cd 替代品

#### Shell 配置
**路徑**: `modules/home/programs/shell/`
**命名空間**: `killtw.programs.shell`

- **zsh**: Zsh shell 配置與插件

#### Terminal 終端工具
**路徑**: `modules/home/programs/terminal/`
**命名空間**: `killtw.programs.terminal`

- **alacritty**: GPU 加速終端模擬器
- **tmux**: 終端多工器

#### Cloud 雲端工具
**路徑**: `modules/home/programs/cloud/`
**命名空間**: `killtw.programs.cloud`

- **awscli**: AWS 命令行工具
- **colima**: 容器運行時
- **gcp**: Google Cloud 工具

### 3. 套件模組 (Suites)

**路徑**: `modules/home/suites/`
**命名空間**: `killtw.suites`

#### Common Suite
包含基礎開發環境：
- git, direnv (開發基礎)
- zsh (現代化 shell)
- bat, eza, fzf, zoxide, starship (系統工具)
- alacritty, tmux (終端工具)

#### Development Suite
包含進階開發工具：
- kubectl, helm (Kubernetes)
- awscli, gcp, colima (雲端工具)

## 配置選項

### 基礎選項

每個模組都包含以下基礎選項：

```nix
{
  enable = mkEnableOption "模組名稱";
  package = mkOption {
    type = types.nullOr types.package;
    default = null;
    description = "要使用的套件，null 則使用預設";
  };
  aliases = mkOption {
    type = types.attrsOf types.str;
    default = {};
    description = "Shell 別名";
  };
  extraConfig = mkOption {
    type = types.attrs;
    default = {};
    description = "額外配置選項";
  };
}
```

### Suite 選項

```nix
{
  enable = mkEnableOption "套件名稱";
  modules = mkOption {
    type = types.listOf (types.enum availableModules);
    default = availableModules;
    description = "要啟用的模組列表";
  };
  excludeModules = mkOption {
    type = types.listOf (types.enum availableModules);
    default = [];
    description = "要排除的模組列表";
  };
}
```

## 輔助函數

### lib/home.nix 提供的函數

1. **mkTerminalOptions**: 終端應用程式選項模板
2. **mkDevelopmentToolOptions**: 開發工具選項模板
3. **mkSystemToolOptions**: 系統工具選項模板
4. **mkCloudToolOptions**: 雲端工具選項模板
5. **mkSuiteOptions**: 套件選項模板
6. **mkAppAssertions**: 應用程式斷言檢查
7. **mkPackageWithFallback**: 套件回退機制

### 使用範例

```nix
# 在模組中使用
options.killtw.programs.terminal.myapp = mkTerminalOptions "MyApp" // {
  # 額外的特定選項
  customOption = mkStrOpt "default" "自定義選項";
};
```

## 設計原則

### 1. 一致性
- 所有模組使用相同的命名空間結構
- 統一的選項命名慣例
- 一致的配置模式

### 2. 可組合性
- 模組可以獨立啟用或停用
- Suite 提供預配置的組合
- 支援選擇性模組啟用

### 3. 可擴展性
- 易於添加新模組
- 清晰的模組分類
- 標準化的選項結構

### 4. 可維護性
- 模組化設計減少重複
- 輔助函數簡化開發
- 清晰的文檔和註釋

## 最佳實踐

### 1. 模組開發
- 使用適當的選項模板函數
- 添加必要的斷言檢查
- 提供合理的預設值
- 包含完整的文檔

### 2. 配置管理
- 優先使用 suites 而非個別模組
- 使用命名空間避免衝突
- 保持配置簡潔明瞭

### 3. 測試
- 使用 `nix-instantiate --parse` 檢查語法
- 使用 `nix build --dry-run` 測試構建
- 確保所有模組都被 git 追蹤

## 故障排除

### 常見問題

1. **模組未被識別**
   ```bash
   git add .  # 確保文件被 git 追蹤
   ```

2. **選項不存在**
   - 檢查命名空間是否正確
   - 確認模組已正確導入

3. **構建失敗**
   ```bash
   nix build --show-trace  # 顯示詳細錯誤
   ```

### 調試工具

```bash
# 檢查模組識別
nix eval .#homeModules --apply builtins.attrNames

# 檢查配置
nix eval .#homeConfigurations.killtw@mini.config

# 語法檢查
nix-instantiate --parse modules/home/path/to/module.nix
```

## 版本控制

### Git 工作流程

1. **開發新模組**
   ```bash
   # 創建模組文件
   # 測試語法
   nix-instantiate --parse modules/home/new-module/default.nix
   # 添加到 git
   git add .
   # 測試構建
   nix build --dry-run .#homeConfigurations.killtw@mini.activationPackage
   ```

2. **更新現有模組**
   ```bash
   # 修改模組
   # 測試變更
   # 提交變更
   git commit -m "feat: update module xyz"
   ```

## 擴展指南

### 添加新模組

1. **創建模組目錄**
   ```bash
   mkdir -p modules/home/programs/category/new-tool
   ```

2. **創建模組文件**
   ```nix
   # modules/home/programs/category/new-tool/default.nix
   { lib, pkgs, config, namespace, ... }:
   
   with lib;
   with lib.${namespace};
   
   let
     cfg = config.${namespace}.programs.category.new-tool;
   in
   {
     options.${namespace}.programs.category.new-tool = mkCategoryToolOptions "NewTool";
     
     config = mkIf cfg.enable {
       assertions = mkAppAssertions "NewTool" cfg;
       
       programs.new-tool = {
         enable = true;
         package = mkPackageWithFallback cfg pkgs.new-tool;
       } // cfg.extraConfig;
     };
   }
   ```

3. **添加到 suite**
   ```nix
   # 在相關 suite 中添加模組
   availableModules = [ "existing-modules" "new-tool" ];
   ```

4. **測試和提交**
   ```bash
   git add .
   nix build --dry-run .#homeConfigurations.killtw@mini.activationPackage
   git commit -m "feat: add new-tool module"
   ```

這個架構提供了一個強大、靈活且易於維護的 Nix 配置系統，支援現代化的開發工作流程。
