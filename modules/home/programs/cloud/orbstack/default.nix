# OrbStack container runtime module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.orbstack;
in
{
  options.${namespace}.programs.cloud.orbstack = mkCloudToolOptions "OrbStack" // {
    # OrbStack-specific options
    enableDocker = mkBoolOpt true "Enable Docker compatibility";
    enableDockerCompose = mkBoolOpt true "Enable Docker Compose";

    # Installation method (for documentation and path detection only)
    installMethod = mkEnumOpt [ "homebrew" "manual" ] "homebrew" "Installation method for OrbStack (affects CLI path detection)";

    # Resource configuration (OrbStack manages these automatically but we can provide hints)
    cpu = mkIntOpt 0 "CPU cores hint (0 = auto)";
    memory = mkIntOpt 0 "Memory in GB hint (0 = auto)";
    disk = mkIntOpt 0 "Disk size in GB hint (0 = auto)";

    # OrbStack settings
    autoStart = mkBoolOpt false "Auto start OrbStack on login";
    enableKubernetes = mkBoolOpt false "Enable Kubernetes support";

    # Docker socket configuration
    dockerSocket = mkStrOpt "/var/run/docker.sock" "Docker socket path";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for OrbStack";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "OrbStack" cfg ++ [
      {
        assertion = cfg.cpu >= 0;
        message = "OrbStack CPU hint must be non-negative (0 = auto)";
      }
      {
        assertion = cfg.memory >= 0;
        message = "OrbStack memory hint must be non-negative (0 = auto)";
      }
      {
        assertion = cfg.disk >= 0;
        message = "OrbStack disk hint must be non-negative (0 = auto)";
      }
    ];

    home.packages = mkConditionalPackages cfg.enableDockerCompose [
      pkgs.docker-compose
    ];

    # Note: OrbStack installation should be managed declaratively via Nix
    # Add to your systems/<arch>/<hostname>/default.nix:
    #
    # killtw.apps = {
    #   extraCasks = [ "orbstack" ];  # This includes both GUI and CLI
    # };
    #
    # CLI paths:
    #    - Homebrew cask: /opt/homebrew/bin/orb (symlink to app bundle)
    #    - Direct app path: /Applications/OrbStack.app/Contents/MacOS/bin/orb
    #    - Manual: /Applications/OrbStack.app/Contents/Resources/bin/orb

    # Auto-start configuration using launchd
    launchd.agents.orbstack = mkIf cfg.autoStart {
      enable = true;
      config = {
        ProgramArguments = [
          "/Applications/OrbStack.app/Contents/MacOS/OrbStack"
          "--background"
        ];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "/tmp/orbstack.out";
        StandardErrorPath = "/tmp/orbstack.err";
        EnvironmentVariables = {
          PATH = "/Applications/OrbStack.app/Contents/Resources/bin:/usr/bin:/bin";
          HOME = config.home.homeDirectory;
        };
      };
    };

    # OrbStack initialization script
    home.file.".local/bin/init-orbstack.sh" = {
      text = ''
        #!/bin/bash

        echo "🚀 Initializing OrbStack..."

        # Function to find OrbStack CLI
        find_orb_cli() {
          # Check Homebrew symlinks first (created by cask installation)
          if [ -f "/opt/homebrew/bin/orb" ]; then
            echo "/opt/homebrew/bin/orb"
            return 0
          elif [ -f "/usr/local/bin/orb" ]; then
            echo "/usr/local/bin/orb"
            return 0
          # Check Homebrew cask direct path
          elif [ -f "/Applications/OrbStack.app/Contents/MacOS/bin/orb" ]; then
            echo "/Applications/OrbStack.app/Contents/MacOS/bin/orb"
            return 0
          # Check manual installation path
          elif [ -f "/Applications/OrbStack.app/Contents/Resources/bin/orb" ]; then
            echo "/Applications/OrbStack.app/Contents/Resources/bin/orb"
            return 0
          # Check if orb is in PATH
          elif command -v orb >/dev/null 2>&1; then
            which orb
            return 0
          else
            return 1
          fi
        }

        # Find OrbStack CLI
        ORB_CLI=$(find_orb_cli)
        if [ $? -ne 0 ]; then
          echo "❌ OrbStack CLI not found. Please install OrbStack declaratively:"
          echo "   Add to your systems/<arch>/<hostname>/default.nix:"
          echo "   killtw.apps = {"
          echo "     extraCasks = [ \"orbstack\" ];"
          echo "   };"
          echo ""
          echo "   Then run: sudo nix run nix-darwin -- switch --flake ~/.config/nix"
          exit 1
        fi

        echo "✅ Found OrbStack CLI at: $ORB_CLI"

        # Add OrbStack CLI directory to PATH for this session
        ORB_DIR=$(dirname "$ORB_CLI")
        export PATH="$ORB_DIR:$PATH"

        # Start OrbStack if not running
        if ! orb status >/dev/null 2>&1; then
          echo "🔄 Starting OrbStack..."
          orb start
        else
          echo "✅ OrbStack is already running"
        fi

        ${optionalString cfg.enableKubernetes ''
        # Enable Kubernetes if requested
        echo "☸️  Configuring Kubernetes..."
        orb config set kubernetes.enabled true
        ''}

        ${optionalString (cfg.cpu > 0) ''
        # Set CPU hint
        echo "🔧 Setting CPU hint to ${toString cfg.cpu} cores..."
        orb config set resources.cpu ${toString cfg.cpu}
        ''}

        ${optionalString (cfg.memory > 0) ''
        # Set memory hint
        echo "🔧 Setting memory hint to ${toString cfg.memory}GB..."
        orb config set resources.memory ${toString cfg.memory}G
        ''}

        ${optionalString (cfg.disk > 0) ''
        # Set disk hint
        echo "🔧 Setting disk hint to ${toString cfg.disk}GB..."
        orb config set resources.disk ${toString cfg.disk}G
        ''}

        echo "🎉 OrbStack initialization complete!"
      '';
      executable = true;
    };

    # Status checking script
    home.file.".local/bin/orbstack-status.sh" = {
      text = ''
        #!/bin/bash

        echo "🌌 OrbStack Status Report"
        echo "========================"
        echo ""

        # Function to find OrbStack CLI (same as init script)
        find_orb_cli() {
          # Check Homebrew symlinks first (created by cask installation)
          if [ -f "/opt/homebrew/bin/orb" ]; then
            echo "/opt/homebrew/bin/orb"
            return 0
          elif [ -f "/usr/local/bin/orb" ]; then
            echo "/usr/local/bin/orb"
            return 0
          # Check Homebrew cask direct path
          elif [ -f "/Applications/OrbStack.app/Contents/MacOS/bin/orb" ]; then
            echo "/Applications/OrbStack.app/Contents/MacOS/bin/orb"
            return 0
          # Check manual installation path
          elif [ -f "/Applications/OrbStack.app/Contents/Resources/bin/orb" ]; then
            echo "/Applications/OrbStack.app/Contents/Resources/bin/orb"
            return 0
          # Check if orb is in PATH
          elif command -v orb >/dev/null 2>&1; then
            which orb
            return 0
          else
            return 1
          fi
        }

        # Find OrbStack CLI
        ORB_CLI=$(find_orb_cli)
        if [ $? -ne 0 ]; then
          echo "❌ OrbStack CLI not found. Please install OrbStack declaratively:"
          echo "   Add to your systems/<arch>/<hostname>/default.nix:"
          echo "   killtw.apps = {"
          echo "     extraCasks = [ \"orbstack\" ];"
          echo "   };"
          echo ""
          echo "   Then run: sudo nix run nix-darwin -- switch --flake ~/.config/nix"
          exit 1
        fi

        # Add OrbStack CLI directory to PATH for this session
        ORB_DIR=$(dirname "$ORB_CLI")
        export PATH="$ORB_DIR:$PATH"

        # OrbStack status
        echo "🖥️  OrbStack Status:"
        if orb status >/dev/null 2>&1; then
          orb status
        else
          echo "   OrbStack is not running"
        fi
        echo ""

        # Docker status
        echo "🐳 Docker Status:"
        if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
          echo "   Docker is running"
          docker version --format "   Docker {{.Server.Version}} (API {{.Server.APIVersion}})"
        else
          echo "   Docker is not available"
        fi
        echo ""

        # Container status
        echo "📦 Container Status:"
        if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
          docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        else
          echo "   Cannot connect to Docker"
        fi
        echo ""

        # Kubernetes status
        echo "☸️  Kubernetes Status:"
        if orb config get kubernetes.enabled 2>/dev/null | grep -q "true"; then
          echo "   Kubernetes is enabled"
          if command -v kubectl >/dev/null 2>&1; then
            kubectl version --client --short 2>/dev/null || echo "   kubectl available"
          fi
        else
          echo "   Kubernetes is disabled"
        fi
        echo ""

        # Resource usage
        echo "📊 Resource Usage:"
        orb info 2>/dev/null || echo "   Resource information not available"
      '';
      executable = true;
    };

    # OrbStack logs script
    home.file.".local/bin/orbstack-logs.sh" = {
      text = ''
        #!/bin/bash

        echo "📋 OrbStack Logs"
        echo "================"
        echo ""

        if [ -f "/tmp/orbstack.out" ]; then
          echo "📄 Latest OrbStack output:"
          tail -50 /tmp/orbstack.out
        else
          echo "❌ No OrbStack logs found"
        fi

        echo ""
        if [ -f "/tmp/orbstack.err" ]; then
          echo "⚠️  Latest OrbStack errors:"
          tail -20 /tmp/orbstack.err
        fi

        echo ""
        echo "💡 For more detailed logs, check:"
        echo "   ~/Library/Logs/OrbStack/"
      '';
      executable = true;
    };

    # OrbStack management script
    home.file.".local/bin/orbstack-manage.sh" = {
      text = ''
        #!/bin/bash

        case "$1" in
          start)
            echo "🚀 Starting OrbStack..."
            orb start
            ;;
          stop)
            echo "🛑 Stopping OrbStack..."
            orb stop
            ;;
          restart)
            echo "🔄 Restarting OrbStack..."
            orb restart
            ;;
          reset)
            echo "⚠️  Resetting OrbStack..."
            read -p "This will reset all containers and data. Continue? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
              orb reset
            else
              echo "Reset cancelled"
            fi
            ;;
          update)
            echo "📦 Updating OrbStack..."
            orb update
            ;;
          *)
            echo "Usage: $0 {start|stop|restart|reset|update}"
            echo ""
            echo "Commands:"
            echo "  start   - Start OrbStack"
            echo "  stop    - Stop OrbStack"
            echo "  restart - Restart OrbStack"
            echo "  reset   - Reset OrbStack (removes all data)"
            echo "  update  - Update OrbStack"
            exit 1
            ;;
        esac
      '';
      executable = true;
    };

    # Shell aliases
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      # Docker aliases (OrbStack provides Docker compatibility)
      docker = mkIf cfg.enableDocker "docker";
      dc = mkIf cfg.enableDockerCompose "docker compose";
    } // {
      orbstack-status = "~/.local/bin/orbstack-status.sh";
      orbstack-logs = "~/.local/bin/orbstack-logs.sh";
      orbstack-manage = "~/.local/bin/orbstack-manage.sh";
      orb-init = "~/.local/bin/init-orbstack.sh";
    });
  };
}
