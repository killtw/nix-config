# Podman 容器自動更新整合

這個模組為 Podman 添加了智能容器更新功能，提供完整的容器運行環境管理，讓您可以聲明式地管理 Podman machine 和容器的自動更新。

## 🎯 核心特色

### 🚀 Podman Machine 管理
- 自動初始化和啟動 Podman machine
- 支援自定義資源配置（CPU、記憶體、磁碟）
- 使用 launchd 管理開機自動啟動
- Rootless 容器執行（更安全）

### 🔄 原生自動更新
- 使用 Podman 原生 `auto-update` 功能
- 支援 label-based 更新控制
- 自動排程更新檢查
- 智能映像檔清理

### 🏷️ Label-Enable 功能
- 預設啟用 label-based 更新控制
- 只有明確標記的容器才會被自動更新
- 使用標準 `io.containers.autoupdate=registry` 標籤
- 提供精細的更新控制

### 🛠️ 豐富的管理工具
- `podman-status`: 查看 machine 和容器狀態
- `podman-autoupdate-logs`: 查看更新日誌
- `podman-autoupdate`: 手動觸發更新檢查
- `podman-init`: 初始化 Podman machine

## 配置選項

```nix
killtw.programs.cloud.podman = {
  enable = false;                    # 啟用 Podman
  autoStart = false;                 # 開機自動啟動
  
  # Machine 配置
  cpu = 2;                          # CPU 核心數
  memory = 4;                       # 記憶體 (GB)
  disk = 60;                        # 磁碟空間 (GB)
  machineName = "podman-machine-default";  # Machine 名稱
  rootless = true;                  # Rootless 模式
  
  # 工具啟用
  enablePodmanDesktop = true;       # Podman Desktop GUI
  enableDockerCompose = true;       # Docker Compose 相容性
  enablePodmanCompose = true;       # podman-compose
  
  # 自動更新配置
  autoUpdate = {
    enable = true;                  # 啟用自動更新
    labelEnable = true;             # 只更新有標籤的容器
    schedule = "0 0 4 * * *";       # Cron 排程（預設每天 4AM）
    cleanup = true;                 # 清理舊映像檔
    debug = false;                  # 除錯模式
    
    notifications = {
      enable = false;               # 啟用通知
      url = "";                     # 通知 URL
    };
  };
  
  # 自定義別名
  aliases = {
    pps = "podman ps";
    pimg = "podman images";
  };
};
```

## 使用方式

### 1. 啟用功能

```nix
{
  killtw.programs.cloud.podman = {
    enable = true;
    autoStart = true;
    autoUpdate.enable = true;
  };
}
```

### 2. 標記容器以啟用自動更新

**Podman 命令：**
```bash
podman run -d \
  --label io.containers.autoupdate=registry \
  nginx
```

**Containerfile/Dockerfile：**
```dockerfile
FROM nginx
LABEL io.containers.autoupdate=registry
```

**Docker Compose（使用 podman-compose）：**
```yaml
services:
  web:
    image: nginx
    labels:
      - io.containers.autoupdate=registry
```

### 3. 管理容器更新

```bash
# 查看狀態
podman-status

# 手動觸發更新檢查
podman-autoupdate

# 查看更新日誌
podman-autoupdate-logs

# 初始化 machine（如果需要）
podman-init
```

### 4. Podman 特有操作

```bash
# Machine 管理
podman machine list
podman machine start <name>
podman machine stop <name>

# 容器管理
podman ps
podman images
podman auto-update --dry-run  # 預覽更新

# Kubernetes 支援
podman play kube deployment.yaml
podman generate kube my-pod
```

## 自動更新標籤

Podman 支援以下自動更新標籤：

- `io.containers.autoupdate=registry` - 從 registry 檢查更新
- `io.containers.autoupdate=local` - 從本地檢查更新  
- `io.containers.autoupdate=disabled` - 停用自動更新（預設）

## Docker Compose 相容性

### 使用 podman-compose
```bash
# 安裝後可直接使用
podman-compose up -d
podman-compose down
```

### 使用 docker-compose
```bash
# 透過 Podman socket（需要額外設定）
export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock
docker-compose up -d
```

## 排程格式

使用標準 Cron 格式：
- `0 0 4 * * *` - 每天凌晨 4 點
- `0 0 */6 * * *` - 每 6 小時
- `0 30 2 * * 0` - 每週日凌晨 2:30

## 安全優勢

- **Rootless 執行**：容器以非 root 用戶執行
- **無 daemon**：不需要特權 daemon 運行
- **SELinux 支援**：更好的安全隔離
- **Label 控制**：精確控制哪些容器可以更新

## 故障排除

### Machine 未啟動
```bash
# 檢查 machine 狀態
podman machine list

# 手動啟動
podman machine start <name>

# 重新初始化
podman-init
```

### 容器未被更新
```bash
# 確認容器有正確標籤
podman inspect <container> | grep autoupdate

# 手動測試更新
podman auto-update --dry-run

# 檢查更新日誌
podman-autoupdate-logs
```

### Docker Compose 問題
```bash
# 檢查 Podman socket
podman system service --time=0 unix:///tmp/podman.sock

# 設定環境變數
export DOCKER_HOST=unix:///tmp/podman.sock
```

## 與 Colima 的比較

| 功能 | Podman | Colima |
|------|--------|--------|
| 安全性 | Rootless, 無 daemon | VM 隔離 |
| 資源消耗 | 較低 | 較高（VM overhead） |
| 自動更新 | 原生支援 | Watchtower 整合 |
| Kubernetes | podman play kube | 內建 K8s 支援 |
| Docker 相容性 | 高度相容 | 完全相容 |

## 進階配置

### 自定義排程
```nix
autoUpdate.schedule = "0 0 2 * * 1-5";  # 工作日凌晨 2 點
```

### 啟用除錯
```nix
autoUpdate.debug = true;
```

### 自定義 Machine
```nix
machineName = "my-dev-machine";
cpu = 8;
memory = 16;
```
