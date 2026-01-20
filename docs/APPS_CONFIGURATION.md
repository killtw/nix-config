# 應用程式配置指南

## 概述

新的應用程式管理系統提供了一個簡潔的方式來管理 macOS 應用程式安裝。系統分為兩個層次：

1. **基礎層** (`modules/darwin/apps/default.nix`)：定義所有使用者共用的基本應用程式清單
2. **系統層** (`systems/*/default.nix`)：允許每個系統/主機添加額外的應用程式

## 基礎應用程式清單

基礎清單包含以下應用程式：

### 系統套件 (Nix packages)
- devbox
- ffmpeg  
- git
- iina
- wget

### Homebrew Brews
- bitwarden-cli

### Homebrew Casks
- **開發工具**: visual-studio-code, tableplus, lens
- **生產力工具**: arc, raycast
- **媒體工具**: sonos
- **系統工具**: adguard, airbuddy, betterdisplay, itsycal, jordanbaird-ice, karabiner-elements, surge
- **創意工具**: bambu-studio, thumbhost3mf
- **通訊工具**: dingtalk
- **遊戲工具**: sony-ps-remote-play

### Mac App Store 應用程式
- Bitwarden (1352778147)
- Keynote (409183694)
- Numbers (409203825)
- Pages (409201541)
- PopClip (445189367)
- The Unarchiver (425424353)
- LINE (539883307)

## 系統配置

在您的系統配置中，您可以啟用基礎應用程式並添加額外需求：

### 基本配置

```nix
# systems/aarch64-darwin/hostname/default.nix
{
  killtw = {
    apps = {
      enable = true;  # 啟用基礎應用程式清單
    };
  };
}
```

### 添加額外應用程式

```nix
{
  killtw = {
    apps = {
      enable = true;

      # 額外的 Homebrew taps
      extraTaps = [
        "homebrew/cask-fonts"
        "homebrew/cask-drivers"
      ];

      # 額外的 Homebrew brews
      extraBrews = [
        "htop"
        "tree"
        "jq"
        "curl"
      ];

      # 額外的 Homebrew casks
      extraCasks = [
        "docker"
        "postman"
        "font-sauce-code-pro-nerd-font"
        "notion"
      ];

      # 額外的 Mac App Store 應用程式
      extraMasApps = {
        "Xcode" = 497799835;
        "TestFlight" = 899247664;
        "Pixelmator Pro" = 1289583905;
      };

      # 額外的系統套件
      extraPackages = with pkgs; [
        nodejs
        python3
        go
      ];
    };
  };
}
```

## 配置範例

### 最小配置 (基本系統)
```nix
# systems/aarch64-darwin/hostname/default.nix
{
  killtw = {
    apps.enable = true;
  };
}
```

### 開發者配置
```nix
# systems/aarch64-darwin/hostname/default.nix
{
  killtw = {
    apps = {
      enable = true;
      extraTaps = [ "homebrew/cask-fonts" ];
      extraBrews = [ "htop" "tree" "jq" ];
      extraCasks = [ "docker" "postman" ];
      extraMasApps = { "Xcode" = 497799835; };
    };
  };
}
```

### 設計師配置
```nix
# systems/aarch64-darwin/hostname/default.nix
{
  killtw = {
    apps = {
      enable = true;
      extraCasks = [
        "figma"
        "sketch"
        "adobe-creative-cloud"
      ];
      extraMasApps = {
        "Pixelmator Pro" = 1289583905;
        "Affinity Designer" = 824171161;
      };
    };
  };
}
```

## 修改基礎清單

如果需要修改所有使用者共用的基礎應用程式清單，請編輯 `modules/darwin/apps/default.nix`：

1. 在相應的陣列中添加或移除應用程式
2. 確保 cask 名稱正確
3. 確保 Mac App Store ID 正確
4. 提交變更並重新建置配置

## 注意事項

- 所有使用者都會獲得基礎清單中的應用程式
- 使用 `extraXxx` 選項來添加個人需求，不會影響其他使用者
- Mac App Store ID 可以從 App Store URL 或使用 `mas search "App Name"` 命令獲得
- Homebrew cask 名稱可以使用 `brew search --cask "app name"` 查詢
