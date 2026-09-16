# Darwin Homebrew configuration module
{ lib, pkgs, config, namespace, inputs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.homebrew;
  homebrewCurl = pkgs.writeShellScript "homebrew-curl-global" ''
    #!/bin/bash
    set -euo pipefail

    # Homebrew asks curl to print its selected executable during diagnostics.
    if (( $# > 0 )) && [[ "$1" == "--homebrew=print-path" ]]; then
      printf '%s\n' /usr/bin/curl
      exit 0
    fi

    browser_user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/18.0 Safari/605.1.15'
    homebrew_args=()
    skip_user_agent_value=0
    for arg in "$@"; do
      if (( skip_user_agent_value == 1 )); then
        skip_user_agent_value=0
        continue
      fi

      case "$arg" in
        -A|--user-agent)
          skip_user_agent_value=1
          homebrew_args+=(-d-user-agent "$browser_user_agent")
          ;;
        -A?*)
          homebrew_args+=(--user-agent "$browser_user_agent")
          ;;
        --user-agent=*)
          homebrew_args+=(--user-agent="$browser_user_agent")
          ;;
        *)
          homebrew_args+=("$arg")
          ;;
      esac
    done

    exec /usr/bin/curl "''${homebrew_args[@]}"
  '';
in
{
  options.${namespace}.homebrew = {
    enable = mkBoolOpt true "Whether to enable Homebrew configuration.";
    username = mkStrOpt "killtw" "The username for nix-homebrew.";
  };

  config = mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = false;
      user = cfg.username;

      mutableTaps = true;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;

      onActivation = {
        cleanup = "zap";
        autoUpdate = false;
        upgrade = true;
      };
    };

    # 設定 homebrew 環境變數
    environment.variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_AUTO_UPDATE = "1";
      HOMEBREW_CURL_PATH = "${homebrewCurl}";
      EDITOR = "nvim";
    };
  };
}
