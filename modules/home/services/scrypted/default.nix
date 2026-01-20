{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.services.scrypted;

  # Python environment for Scrypted
  # Scrypted requires: debugpy, typing_extensions, opencv-python
  # We use opencv4 from nixpkgs which provides python bindings
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    debugpy
    typing-extensions
    opencv4
    pip
    setuptools
    wheel
  ]);

  # Node.js environment
  # Scrypted script specifies Node 22
  nodeEnv = pkgs.nodejs_22;

  # Wrapper script to start Scrypted
  scrypted-start = pkgs.writeShellScriptBin "scrypted-start" ''
    export PATH="${nodeEnv}/bin:${pythonEnv}/bin:$PATH"
    export NODE_OPTIONS="--dns-result-order=ipv4first"
    export SCRYPTED_PYTHON_PATH="${pythonEnv}/bin/python"
    
    # Create data directory if it doesn't exist
    mkdir -p "$HOME/.scrypted"
    
    echo "Starting Scrypted..."
    echo "Node: $(node --version)"
    echo "Python: $(python --version)"
    
    # Run scrypted serve using npx
    # -y: yes to prompts
    exec npx -y scrypted@latest serve
  '';
in
{
  options.${namespace}.services.scrypted = {
    enable = mkEnableOption "Scrypted Home Automation Platform";
  };

  config = mkIf cfg.enable {
    # Install dependencies into user profile
    home.packages = [
      scrypted-start
      nodeEnv
      pythonEnv
    ];

    # macOS LaunchAgent configuration
    launchd.agents.scrypted = mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        Label = "app.scrypted.server";
        ProgramArguments = [ "${scrypted-start}/bin/scrypted-start" ];
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "${config.home.homeDirectory}/.scrypted";
        StandardOutPath = "${config.home.homeDirectory}/.scrypted/scrypted.log";
        StandardErrorPath = "${config.home.homeDirectory}/.scrypted/scrypted.error.log";
        EnvironmentVariables = {
           NODE_OPTIONS = "--dns-result-order=ipv4first";
           SCRYPTED_PYTHON_PATH = "${pythonEnv}/bin/python";
           # We explicitly set PATH to ensure node and python are found
           PATH = "${nodeEnv}/bin:${pythonEnv}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
           HOME = config.home.homeDirectory;
        };
      };
    };
  };
}
