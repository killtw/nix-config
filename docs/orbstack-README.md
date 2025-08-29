# OrbStack 容器運行環境整合

這個模組為 OrbStack 提供完整的 Nix 配置整合，讓您可以聲明式地管理 OrbStack 容器運行環境和相關配置。

## 🎯 核心特色

### 🚀 原生 macOS 整合
- 無需虛擬化，直接使用 macOS 核心功能
- 極快的啟動速度和檔案系統性能
- 自動資源管理，無需手動調整
- 原生網路和檔案系統整合

### 🐳 完整 Docker 相容性
- 100% Docker API 相容
- 支援所有 Docker 和 Docker Compose 命令
- 無縫替換 Docker Desktop
- 支援現有的 Dockerfile 和 docker-compose.yml

### ☸️ Kubernetes 支援
- 內建 Kubernetes 集群
- 一鍵啟用/停用
- 與 kubectl 完全整合
- 支援本地開發和測試

### 🛠️ 豐富的管理工具
- `orbstack-status`: 查看系統和容器狀態
- `orbstack-manage`: 完整的生命週期管理
- `orbstack-logs`: 日誌查看和故障排除
- `orb-init`: 自動初始化和配置

## 配置選項

```nix
killtw.programs.cloud.orbstack = {
  enable = false;                    # 啟用 OrbStack
  autoStart = false;                 # 開機自動啟動
  
  # 資源配置提示（OrbStack 自動管理）
  cpu = 0;                          # CPU 核心數（0 = 自動）
  memory = 0;                       # 記憶體 GB（0 = 自動）
  disk = 0;                         # 磁碟空間 GB（0 = 自動）
  
  # 功能啟用
  enableDocker = true;              # Docker 相容性
  enableDockerCompose = true;       # Docker Compose 支援
  enableKubernetes = false;         # Kubernetes 支援
  
  # 配置
  dockerSocket = "/var/run/docker.sock";  # Docker socket 路徑
  
  # 自定義別名
  aliases = {
    dps = "docker ps";
    dimg = "docker images";
  };
};
```

## 使用方式

### 1. 啟用功能

```nix
{
  killtw.programs.cloud.orbstack = {
    enable = true;
    autoStart = true;
  };
}
```

### 2. 透過 Development Suite 啟用

```nix
{
  killtw.suites.development = {
    enable = true;
    modules = ["orbstack"];  # 只啟用 orbstack
  };
}
```

### 3. 基本容器操作

```bash
# 標準 Docker 命令
docker run hello-world
docker ps
docker images

# Docker Compose
docker-compose up -d
docker-compose down
```

### 4. 管理 OrbStack

```bash
# 查看狀態
orbstack-status

# 管理服務
orbstack-manage start    # 啟動
orbstack-manage stop     # 停止
orbstack-manage restart  # 重新啟動
orbstack-manage reset    # 重置（清除所有資料）
orbstack-manage update   # 更新

# 查看日誌
orbstack-logs

# 初始化配置
orb-init
```

### 5. Kubernetes 使用

```bash
# 啟用 Kubernetes（需要在配置中設定 enableKubernetes = true）
kubectl get nodes
kubectl create deployment nginx --image=nginx
kubectl get pods
```

## 資源管理

OrbStack 的一大優勢是自動資源管理：

- **CPU**: 根據工作負載自動調整
- **記憶體**: 動態分配，不使用時自動釋放
- **磁碟**: 智能壓縮和清理
- **網路**: 原生 macOS 網路堆疊

配置中的資源設定為「提示值」，OrbStack 會參考但不嚴格限制。

## 與其他容器運行環境的比較

| 功能 | OrbStack | Docker Desktop | colima | podman |
|------|----------|----------------|--------|--------|
| 啟動速度 | 極快 | 慢 | 中等 | 中等 |
| 資源消耗 | 極低 | 高 | 中等 | 低 |
| macOS 整合 | 原生 | 良好 | 基本 | 基本 |
| Docker 相容性 | 100% | 100% | 100% | 高 |
| Kubernetes | 內建 | 內建 | 需配置 | 支援 |
| 檔案性能 | 原生 | VirtioFS | SSHFS | 原生 |

## 安裝需求

- macOS 12.0 或更新版本
- Apple Silicon 或 Intel Mac
- 從 [OrbStack 官網](https://orbstack.dev) 或 App Store 安裝 OrbStack 應用程式

## 故障排除

### OrbStack 無法啟動
```bash
# 檢查狀態
orbstack-status

# 查看日誌
orbstack-logs

# 重新啟動
orbstack-manage restart
```

### Docker 命令無法使用
```bash
# 確認 OrbStack 正在運行
orb status

# 檢查 Docker socket
ls -la /var/run/docker.sock

# 重新初始化
orb-init
```

### 容器性能問題
```bash
# 檢查資源使用
orb info

# 清理未使用的資源
docker system prune -a
```

### Kubernetes 問題
```bash
# 檢查 Kubernetes 狀態
kubectl cluster-info

# 重置 Kubernetes
orbstack-manage reset
orb-init  # 重新啟用 Kubernetes
```

## 進階配置

### 自動啟動和資源提示
```nix
orbstack = {
  enable = true;
  autoStart = true;
  cpu = 8;        # 建議使用 8 核心
  memory = 16;    # 建議使用 16GB 記憶體
  disk = 200;     # 建議使用 200GB 磁碟空間
};
```

### 啟用所有功能
```nix
orbstack = {
  enable = true;
  autoStart = true;
  enableDocker = true;
  enableDockerCompose = true;
  enableKubernetes = true;
};
```

### 自定義別名
```nix
orbstack = {
  enable = true;
  aliases = {
    d = "docker";
    dc = "docker-compose";
    k = "kubectl";
    orb-st = "orbstack-status";
  };
};
```

## 最佳實踐

1. **資源配置**: 讓 OrbStack 自動管理資源，只在特殊需求時設定提示值
2. **自動啟動**: 啟用 `autoStart` 以獲得最佳用戶體驗
3. **定期更新**: 使用 `orbstack-manage update` 保持最新版本
4. **監控狀態**: 定期使用 `orbstack-status` 檢查系統狀態
5. **清理資源**: 定期執行 `docker system prune` 清理未使用的資源

## 遷移指南

### 從 Docker Desktop 遷移
1. 停止 Docker Desktop
2. 啟用 OrbStack 配置
3. 重新構建 Nix 配置
4. 所有現有的 Docker 命令和腳本無需修改

### 從 colima 遷移
1. 停止 colima: `colima stop`
2. 啟用 OrbStack，停用 colima
3. 重新構建配置
4. 現有容器需要重新創建

### 從 podman 遷移
1. 停止 podman machine
2. 啟用 OrbStack，停用 podman
3. 重新構建配置
4. 將 `podman` 命令改為 `docker`

OrbStack 提供了最接近原生 macOS 體驗的容器運行環境，特別適合重視性能和簡潔性的開發者。
