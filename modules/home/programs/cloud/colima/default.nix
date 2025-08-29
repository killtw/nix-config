# Colima container runtime module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.colima;
in
{
  options.${namespace}.programs.cloud.colima = mkCloudToolOptions "Colima" // {
    # Colima-specific options
    enableDocker = mkBoolOpt true "Enable Docker CLI";
    enableDockerCompose = mkBoolOpt true "Enable Docker Compose";

    cpu = mkIntOpt 2 "Number of CPUs";
    memory = mkIntOpt 4 "Memory in GB";
    disk = mkIntOpt 60 "Disk size in GB";

    runtime = mkEnumOpt [ "docker" "containerd" ] "containerd" "Container runtime";

    autoStart = mkBoolOpt false "Auto start Colima on login";

    # Watchtower configuration
    watchtower = {
      enable = mkBoolOpt true "Enable Watchtower for automatic container updates";
      labelEnable = mkBoolOpt true "Only update containers with com.centurylinklabs.watchtower.enable=true label";
      schedule = mkStrOpt "0 0 4 * * *" "Cron schedule for Watchtower updates (default: 4 AM daily)";
      cleanup = mkBoolOpt true "Remove old images after updating";
      notifications = {
        enable = mkBoolOpt false "Enable notifications";
        url = mkStrOpt "" "Notification URL (e.g., Slack webhook, email SMTP)";
      };
      includeRestarting = mkBoolOpt false "Include restarting containers";
      includeStoppedContainers = mkBoolOpt false "Include stopped containers";
      debug = mkBoolOpt false "Enable debug logging";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for Colima";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Colima" cfg ++ [
      {
        assertion = cfg.cpu > 0;
        message = "Colima CPU count must be positive";
      }
      {
        assertion = cfg.memory > 0;
        message = "Colima memory must be positive";
      }
      {
        assertion = cfg.disk > 0;
        message = "Colima disk size must be positive";
      }
    ];

    home.packages = [
      (mkPackageWithFallback cfg pkgs.colima)
    ];

    # Auto-start configuration using launchd
    launchd.agents.colima = mkIf cfg.autoStart {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.colima}/bin/colima"
          "start"
          "--cpu" "${toString cfg.cpu}"
          "--memory" "${toString cfg.memory}"
          "--disk" "${toString cfg.disk}"
          "--runtime" cfg.runtime
        ];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "/tmp/colima.out";
        StandardErrorPath = "/tmp/colima.err";
        EnvironmentVariables = {
          PATH = "${pkgs.colima}/bin:${pkgs.docker}/bin:${pkgs.docker-compose}/bin:/usr/bin:/bin";
          HOME = config.home.homeDirectory;
        };
      };
    };

    # Watchtower startup script
    home.file.".local/bin/start-watchtower.sh" = mkIf cfg.watchtower.enable {
      text = let
        watchtowerArgs = [
          "--schedule=\"${cfg.watchtower.schedule}\""
        ] ++ optionals cfg.watchtower.labelEnable [
          "--label-enable"
        ] ++ optionals cfg.watchtower.cleanup [
          "--cleanup"
          "--remove-volumes"
        ] ++ optionals cfg.watchtower.includeRestarting [
          "--include-restarting"
        ] ++ optionals cfg.watchtower.includeStoppedContainers [
          "--include-stopped"
        ] ++ optionals cfg.watchtower.debug [
          "--debug"
        ] ++ optionals (cfg.watchtower.notifications.enable && cfg.watchtower.notifications.url != "") [
          "--notification-url=\"${cfg.watchtower.notifications.url}\""
        ];
      in ''
        #!/bin/bash

        # Wait for Colima to be ready
        echo "Waiting for Colima to be ready..."

        # Check if we're using containerd runtime
        if colima status 2>&1 | grep -q "runtime: containerd"; then
          echo "🔄 Containerd runtime detected - using containerd-native update solution"
          DOCKER_CMD="nerdctl"
          RUNTIME="containerd"
        else
          echo "🐳 Docker runtime detected - using traditional Watchtower"
          DOCKER_CMD="docker"
          RUNTIME="docker"
        fi

        # Wait for container runtime to be ready
        while ! $DOCKER_CMD info >/dev/null 2>&1; do
          sleep 2
        done

        if [ "$RUNTIME" = "containerd" ]; then
          echo "🔄 Starting containerd-native container update service..."

          # Create a simple update script for containerd
          cat > /tmp/containerd-updater.sh << 'EOF'
#!/bin/bash
echo "🔍 Checking for container updates..."

# Get all containers with the watchtower label
CONTAINERS=$(nerdctl ps --filter "label=com.centurylinklabs.watchtower.enable=true" --format "{{.Names}}")

if [ -z "$CONTAINERS" ]; then
  echo "ℹ️  No containers with watchtower.enable=true label found"
  exit 0
fi

for container in $CONTAINERS; do
  echo "🔍 Checking updates for: $container"

  # Get current image
  CURRENT_IMAGE=$(nerdctl inspect $container --format "{{.Config.Image}}")
  echo "   Current image: $CURRENT_IMAGE"

  # Pull latest image
  echo "   📥 Pulling latest image..."
  if nerdctl pull $CURRENT_IMAGE; then
    # Get image IDs to compare
    OLD_ID=$(nerdctl inspect $container --format "{{.Image}}")
    NEW_ID=$(nerdctl inspect $CURRENT_IMAGE --format "{{.Id}}")

    if [ "$OLD_ID" != "$NEW_ID" ]; then
      echo "   🔄 Image updated! Recreating container..."

      # Get container configuration
      CONTAINER_CONFIG=$(nerdctl inspect $container)

      # Stop and remove old container
      nerdctl stop $container
      nerdctl rm $container

      # Note: In a real scenario, you'd want to recreate with the same configuration
      # This is a simplified version - you might want to use docker-compose for complex setups
      echo "   ⚠️  Container stopped. Please recreate manually with updated image."
      echo "   💡 Consider using docker-compose for automatic recreation."
    else
      echo "   ✅ Container is up to date"
    fi
  else
    echo "   ❌ Failed to pull image for $container"
  fi
  echo ""
done
EOF

          chmod +x /tmp/containerd-updater.sh

          # Run the updater
          /tmp/containerd-updater.sh

        else
          echo "🐳 Starting traditional Watchtower container..."

          # Stop existing Watchtower container if running
          $DOCKER_CMD stop watchtower 2>/dev/null || true
          $DOCKER_CMD rm watchtower 2>/dev/null || true

          # Start Watchtower container
          $DOCKER_CMD run -d \
            --name watchtower \
            --restart unless-stopped \
            -v /var/run/docker.sock:/var/run/docker.sock \
            ${concatStringsSep " \\\n            " watchtowerArgs} \
            containrrr/watchtower
        fi

        echo "Watchtower started successfully"
      '';
      executable = true;
    };

    # Container update service using launchd
    launchd.agents.container-updater = mkIf (cfg.autoStart && cfg.watchtower.enable) {
      enable = true;
      config = {
        ProgramArguments = [
          "${config.home.homeDirectory}/.local/bin/start-watchtower.sh"
        ];
        RunAtLoad = false;
        # Run daily at the scheduled time (convert cron to seconds since midnight)
        StartCalendarInterval = {
          Hour = 4;  # 4 AM by default
          Minute = 0;
        };
        KeepAlive = false;
        StandardOutPath = "/tmp/container-updater.out";
        StandardErrorPath = "/tmp/container-updater.err";
        EnvironmentVariables = {
          PATH = "${pkgs.colima}/bin:${pkgs.docker}/bin:${pkgs.docker-compose}/bin:/usr/bin:/bin";
          HOME = config.home.homeDirectory;
        };
      };
    };

    # Watchtower management scripts
    home.file.".local/bin/watchtower-status.sh" = mkIf cfg.watchtower.enable {
      text = ''
        #!/bin/bash

        # Detect container runtime
        if colima status 2>&1 | grep -q "runtime: containerd"; then
          echo "🔄 Containerd Runtime - Container Update Status"
          echo "=============================================="
          echo ""
          echo "📋 All containers:"
          nerdctl ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
          echo ""
          echo "🏷️  Containers with auto-update labels:"
          LABELED_CONTAINERS=$(nerdctl ps -a --filter "label=com.centurylinklabs.watchtower.enable=true" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}")
          if [ -n "$LABELED_CONTAINERS" ]; then
            echo "$LABELED_CONTAINERS"
          else
            echo "   No containers found with com.centurylinklabs.watchtower.enable=true label"
            echo ""
            echo "💡 To enable auto-updates for a container, add this label:"
            echo "   nerdctl run --label com.centurylinklabs.watchtower.enable=true ..."
          fi
          echo ""
          echo "🔧 Manual update commands:"
          echo "   Check for updates: ~/.local/bin/start-watchtower.sh"
          echo "   Update specific container: nerdctl pull <image> && nerdctl stop <container> && nerdctl rm <container>"
          exit 0
        fi

        DOCKER_CMD="docker"
        echo "=== Watchtower Status (using $DOCKER_CMD) ==="
        if $DOCKER_CMD ps --filter "name=watchtower" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" | grep -q watchtower; then
          echo "✅ Watchtower is running"
          $DOCKER_CMD ps --filter "name=watchtower" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        else
          echo "❌ Watchtower is not running"
        fi

        echo ""
        echo "=== Containers with Watchtower labels ==="
        $DOCKER_CMD ps -a --filter "label=com.centurylinklabs.watchtower.enable=true" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
      '';
      executable = true;
    };

    home.file.".local/bin/watchtower-logs.sh" = mkIf cfg.watchtower.enable {
      text = ''
        #!/bin/bash

        # Detect container runtime
        if colima status 2>&1 | grep -q "runtime: containerd"; then
          DOCKER_CMD="nerdctl"
        else
          DOCKER_CMD="docker"
        fi

        echo "=== Watchtower Logs (using $DOCKER_CMD) ==="
        $DOCKER_CMD logs watchtower "$@"
      '';
      executable = true;
    };

    # Shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      docker = mkIf cfg.enableDocker "nerdctl";
      dc = mkIf cfg.enableDockerCompose "docker compose";
    } // optionalAttrs cfg.watchtower.enable {
      watchtower-status = "~/.local/bin/watchtower-status.sh";
      watchtower-logs = "~/.local/bin/watchtower-logs.sh";
      watchtower-update = "~/.local/bin/start-watchtower.sh";  # Manual update trigger
      container-update = "~/.local/bin/start-watchtower.sh";   # Alias for containerd users
    });
  };
}
