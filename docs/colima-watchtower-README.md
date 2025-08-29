# Colima 容器自動更新整合

這個模組為 Colima 添加了智能容器更新功能，支援 Docker 和 containerd 兩種 runtime，讓您可以聲明式地管理容器的自動更新。

## 🎯 Runtime 支援

### 🐳 Docker Runtime
- 使用傳統的 Watchtower 容器
- 完整的 Watchtower 功能支援
- 自動排程更新

### 🔄 Containerd Runtime
- 使用 containerd 原生更新機制
- 基於 nerdctl 的更新腳本
- 智能映像檔比較和更新

## 功能特色

### 🚀 自動更新
- 支援 Docker 和 containerd runtime
- 使用 launchd 管理定期更新
- 智能 runtime 檢測

### 🏷️ Label-Enable 功能
- 預設啟用 label-based 更新控制
- 只有明確標記的容器才會被自動更新
- 提供精細的更新控制

### ⚙️ 豐富的配置選項
- 自定義更新排程
- 可選的通知功能
- 調試模式支援
- 自動清理舊映像檔

### 🛠️ 管理工具
- `watchtower-status`: 查看容器和更新狀態
- `watchtower-logs`: 查看更新日誌
- `container-update`: 手動觸發更新檢查

## 配置選項

```nix
killtw.programs.cloud.colima.watchtower = {
  enable = false;                    # 啟用 Watchtower
  labelEnable = true;                # 只更新有標籤的容器
  schedule = "0 0 4 * * *";          # Cron 排程（預設每天 4AM）
  cleanup = true;                    # 清理舊映像檔
  debug = false;                     # 除錯模式
  includeRestarting = false;         # 包含重啟中的容器
  includeStoppedContainers = false;  # 包含已停止的容器
  
  notifications = {
    enable = false;                  # 啟用通知
    url = "";                        # 通知 URL
  };
};
```

## 使用方式

### 1. 啟用功能

```nix
{
  killtw.programs.cloud.colima = {
    enable = true;
    autoStart = true;
    watchtower.enable = true;
  };
}
```

### 2. 標記容器以啟用自動更新

**Containerd/nerdctl 命令：**
```bash
nerdctl run -d \
  --label com.centurylinklabs.watchtower.enable=true \
  nginx
```

**Docker 命令：**
```bash
docker run -d \
  --label com.centurylinklabs.watchtower.enable=true \
  nginx
```

**Docker Compose：**
```yaml
services:
  web:
    image: nginx
    labels:
      - com.centurylinklabs.watchtower.enable=true
```

### 3. 管理容器更新

```bash
# 查看狀態（適用於所有 runtime）
watchtower-status

# 手動觸發更新檢查
container-update

# 查看更新日誌
watchtower-logs
```

### 4. Runtime 特定操作

**Containerd 環境：**
```bash
# 檢查容器狀態
nerdctl ps

# 手動更新特定容器
nerdctl pull <image>
nerdctl stop <container>
nerdctl rm <container>
# 然後重新創建容器
```

**Docker 環境：**
```bash
# 檢查 Watchtower 狀態
docker ps --filter name=watchtower

# 重啟 Watchtower
docker restart watchtower
```

## 排程格式

使用標準 Cron 格式：
- `0 0 4 * * *` - 每天凌晨 4 點
- `0 0 */6 * * *` - 每 6 小時
- `0 30 2 * * 0` - 每週日凌晨 2:30

## 通知設定

支援多種通知方式：

```nix
notifications = {
  enable = true;
  url = "slack://token@channel";           # Slack
  # url = "smtp://user:pass@host:port/?from=sender&to=recipient";  # Email
  # url = "discord://token@channel";       # Discord
};
```

## 安全考量

- Watchtower 只能存取 Docker socket
- 使用 label-enable 確保只更新指定容器
- 容器以非特權模式運行
- 自動重啟策略：`unless-stopped`

## 故障排除

### Watchtower 未啟動
```bash
# 檢查 Colima 狀態
colima status

# 檢查 Docker daemon
docker info

# 查看 Watchtower 日誌
watchtower-logs
```

### 容器未被更新
```bash
# 確認容器有正確標籤
docker inspect <container> | grep watchtower

# 檢查 Watchtower 日誌
watchtower-logs -f
```

## 進階配置

### 自定義排程
```nix
watchtower.schedule = "0 0 2 * * 1-5";  # 工作日凌晨 2 點
```

### 啟用除錯
```nix
watchtower.debug = true;
```

### 包含停止的容器
```nix
watchtower.includeStoppedContainers = true;
```
