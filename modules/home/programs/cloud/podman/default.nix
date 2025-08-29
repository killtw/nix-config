# Podman container runtime module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.podman;
in
{
  options.${namespace}.programs.cloud.podman = mkCloudToolOptions "Podman" // {
    # Podman-specific options
    enablePodmanDesktop = mkBoolOpt true "Enable Podman Desktop GUI";
    enableDockerCompose = mkBoolOpt true "Enable Docker Compose compatibility";
    enablePodmanCompose = mkBoolOpt true "Enable podman-compose";

    # Machine configuration
    cpu = mkIntOpt 2 "Number of CPUs for Podman machine";
    memory = mkIntOpt 4 "Memory in GB for Podman machine";
    disk = mkIntOpt 60 "Disk size in GB for Podman machine";

    # Machine settings
    machineName = mkStrOpt "podman-machine-default" "Name of the Podman machine";
    autoStart = mkBoolOpt true "Auto start Podman machine on login";

    # Auto-update configuration
    autoUpdate = {
      enable = mkBoolOpt true "Enable Podman auto-update for containers";
      labelEnable = mkBoolOpt true "Only update containers with io.containers.autoupdate=registry label";
      schedule = mkStrOpt "0 0 4 * * *" "Cron schedule for auto-updates (default: 4 AM daily)";
      cleanup = mkBoolOpt true "Remove old images after updating";
      notifications = {
        enable = mkBoolOpt false "Enable notifications";
        url = mkStrOpt "" "Notification URL (e.g., Slack webhook, email SMTP)";
      };
      debug = mkBoolOpt false "Enable debug logging";
    };

    # Rootless configuration
    rootless = mkBoolOpt true "Run Podman in rootless mode";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for Podman";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Podman" cfg ++ [
      {
        assertion = cfg.cpu > 0;
        message = "Podman CPU count must be positive";
      }
      {
        assertion = cfg.memory > 0;
        message = "Podman memory must be positive";
      }
      {
        assertion = cfg.disk > 0;
        message = "Podman disk size must be positive";
      }
      {
        assertion = cfg.machineName != "";
        message = "Podman machine name cannot be empty";
      }
    ];

    home.packages = [
      (mkPackageWithFallback cfg pkgs.podman)
    ] ++ mkConditionalPackages cfg.enablePodmanDesktop [
      pkgs.podman-desktop
    ] ++ mkConditionalPackages cfg.enableDockerCompose [
      pkgs.docker-compose
    ] ++ mkConditionalPackages cfg.enablePodmanCompose [
      pkgs.podman-compose
    ];

    # Auto-start configuration using launchd
    launchd.agents.podman-machine = mkIf cfg.autoStart {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.podman}/bin/podman"
          "machine"
          "start"
          cfg.machineName
        ];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "/tmp/podman-machine.out";
        StandardErrorPath = "/tmp/podman-machine.err";
        EnvironmentVariables = {
          PATH = "${pkgs.podman}/bin:${pkgs.docker-compose}/bin:/usr/bin:/bin";
          HOME = config.home.homeDirectory;
        };
      };
    };

    # Podman machine initialization script
    home.file.".local/bin/init-podman-machine.sh" = {
      text = ''
        #!/bin/bash

        MACHINE_NAME="${cfg.machineName}"

        echo "🚀 Initializing Podman machine: $MACHINE_NAME"

        # Check if machine already exists
        if podman machine list --format "{{.Name}}" | grep -q "^$MACHINE_NAME$"; then
          echo "✅ Machine $MACHINE_NAME already exists"
        else
          echo "📦 Creating new Podman machine: $MACHINE_NAME"
          podman machine init \
            --cpus ${toString cfg.cpu} \
            --memory ${toString cfg.memory}000 \
            --disk-size ${toString cfg.disk} \
            ${optionalString cfg.rootless "--rootful=false"} \
            "$MACHINE_NAME"
        fi

        # Start the machine if not running
        if ! podman machine list --format "{{.Name}} {{.Running}}" | grep "^$MACHINE_NAME true$" >/dev/null; then
          echo "🔄 Starting Podman machine: $MACHINE_NAME"
          podman machine start "$MACHINE_NAME"
        else
          echo "✅ Machine $MACHINE_NAME is already running"
        fi

        echo "🎉 Podman machine setup complete!"
      '';
      executable = true;
    };

    # Auto-update startup script
    home.file.".local/bin/start-podman-autoupdate.sh" = mkIf cfg.autoUpdate.enable {
      text = let
        autoUpdateArgs = [
          "--dry-run=false"
        ] ++ optionals cfg.autoUpdate.debug [
          "--log-level=debug"
        ];
      in ''
        #!/bin/bash

        echo "🔄 Starting Podman auto-update service..."

        # Wait for Podman machine to be ready
        echo "Waiting for Podman machine to be ready..."
        while ! podman info >/dev/null 2>&1; do
          sleep 2
        done

        echo "✅ Podman is ready"

        # Run auto-update inside the machine
        echo "🔍 Running Podman auto-update..."
        podman machine ssh ${cfg.machineName} -- podman auto-update ${concatStringsSep " " autoUpdateArgs}

        # Cleanup old images if enabled
        ${optionalString cfg.autoUpdate.cleanup ''
        echo "🧹 Cleaning up old images..."
        podman machine ssh ${cfg.machineName} -- podman image prune -f
        ''}

        echo "✅ Auto-update completed"
      '';
      executable = true;
    };

    # Auto-update service using launchd
    launchd.agents.podman-autoupdate = mkIf (cfg.autoStart && cfg.autoUpdate.enable) {
      enable = true;
      config = {
        ProgramArguments = [
          "${config.home.homeDirectory}/.local/bin/start-podman-autoupdate.sh"
        ];
        RunAtLoad = false;
        # Run daily at the scheduled time (convert cron to seconds since midnight)
        StartCalendarInterval = {
          Hour = 4;  # 4 AM by default
          Minute = 0;
        };
        KeepAlive = false;
        StandardOutPath = "/tmp/podman-autoupdate.out";
        StandardErrorPath = "/tmp/podman-autoupdate.err";
        EnvironmentVariables = {
          PATH = "${pkgs.podman}/bin:/usr/bin:/bin";
          HOME = config.home.homeDirectory;
        };
      };
    };

    # Status checking script
    home.file.".local/bin/podman-status.sh" = {
      text = ''
        #!/bin/bash

        echo "🐳 Podman Status Report"
        echo "======================"
        echo ""

        # Machine status
        echo "🖥️  Machine Status:"
        podman machine list
        echo ""

        # Container status
        echo "📦 Container Status:"
        podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        echo ""

        # Auto-update enabled containers
        echo "🔄 Auto-update Enabled Containers:"
        LABELED_CONTAINERS=$(podman ps -a --filter "label=io.containers.autoupdate=registry" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}")
        if [ -n "$LABELED_CONTAINERS" ]; then
          echo "$LABELED_CONTAINERS"
        else
          echo "   No containers found with io.containers.autoupdate=registry label"
          echo ""
          echo "💡 To enable auto-updates for a container, add this label:"
          echo "   podman run -d --label io.containers.autoupdate=registry <image>"
          echo ""
          echo "   Or in a Containerfile/Dockerfile:"
          echo "   LABEL io.containers.autoupdate=registry"
        fi
        echo ""

        # System info
        echo "ℹ️  System Info:"
        podman info --format "{{.Host.OS}} {{.Host.Arch}} - Podman {{.Version.Version}}"
      '';
      executable = true;
    };

    # Auto-update logs script
    home.file.".local/bin/podman-autoupdate-logs.sh" = mkIf cfg.autoUpdate.enable {
      text = ''
        #!/bin/bash

        echo "📋 Podman Auto-update Logs"
        echo "=========================="
        echo ""

        if [ -f "/tmp/podman-autoupdate.out" ]; then
          echo "📄 Latest auto-update output:"
          tail -50 /tmp/podman-autoupdate.out
        else
          echo "❌ No auto-update logs found"
        fi

        echo ""
        if [ -f "/tmp/podman-autoupdate.err" ]; then
          echo "⚠️  Latest auto-update errors:"
          tail -20 /tmp/podman-autoupdate.err
        fi
      '';
      executable = true;
    };

    # Shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      docker = mkIf cfg.enableDockerCompose "podman";
      dc = mkIf cfg.enableDockerCompose "podman-compose";
      docker-compose = mkIf cfg.enablePodmanCompose "podman-compose";
    } // optionalAttrs cfg.autoUpdate.enable {
      podman-status = "~/.local/bin/podman-status.sh";
      podman-autoupdate-logs = "~/.local/bin/podman-autoupdate-logs.sh";
      podman-autoupdate = "~/.local/bin/start-podman-autoupdate.sh";
      podman-init = "~/.local/bin/init-podman-machine.sh";
    });
  };
}
