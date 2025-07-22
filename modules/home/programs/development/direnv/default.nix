# Direnv environment variable management module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.direnv;
in
{
  options.${namespace}.programs.development.direnv = mkDevelopmentToolOptions "Direnv" // {
    # Direnv-specific options
    enableNixDirenvIntegration = mkBoolOpt true "Enable nix-direnv integration";

    silent = mkBoolOpt false "Suppress direnv output";

    stdlib = mkStrOpt "" "Additional direnv stdlib configuration";

    config = mkAttrsOpt {
      warn_timeout = "1h";
      whitelist = {
        prefix = [ "~/code" ];
      };
    } "Direnv configuration";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Direnv" cfg;

    programs.direnv = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.direnv;

      enableZshIntegration = true;

      silent = cfg.silent;

      stdlib = ''
        # Custom direnv stdlib
        ${cfg.stdlib}

        # Layout functions for common development environments
        layout_poetry() {
          if [[ ! -f pyproject.toml ]]; then
            log_error 'No pyproject.toml found. Use `poetry init` to create one first.'
            exit 2
          fi

          local VENV=$(poetry env list --full-path | cut -d' ' -f1)
          if [[ -z $VENV || ! -d $VENV ]]; then
            log_status 'No virtual environment exists. Executing `poetry install` to create one.'
            poetry install
            VENV=$(poetry env list --full-path | cut -d' ' -f1)
          fi

          export VIRTUAL_ENV=$VENV
          export POETRY_ACTIVE=1
          PATH_add "$VENV/bin"
        }

        layout_node() {
          local node_version=''${1:-16}
          if ! command -v node >/dev/null 2>&1; then
            log_error 'Node.js not found. Please install Node.js first.'
            exit 2
          fi

          if [[ -f package.json ]]; then
            log_status 'Found package.json. Installing dependencies...'
            npm install
          fi

          if [[ -f .nvmrc ]]; then
            node_version=$(cat .nvmrc)
            log_status "Using Node.js version from .nvmrc: $node_version"
          fi

          PATH_add node_modules/.bin
        }

        layout_rust() {
          if [[ ! -f Cargo.toml ]]; then
            log_error 'No Cargo.toml found. This does not appear to be a Rust project.'
            exit 2
          fi

          if command -v cargo >/dev/null 2>&1; then
            PATH_add "$(cargo metadata --format-version 1 | jq -r .target_directory)/debug"
          fi
        }

        layout_go() {
          if [[ ! -f go.mod ]]; then
            log_error 'No go.mod found. This does not appear to be a Go project.'
            exit 2
          fi

          export GOPATH="$PWD/.go"
          PATH_add "$GOPATH/bin"
          PATH_add "$(go env GOROOT)/bin"
        }
      '';

      config = cfg.config // cfg.extraConfig;
    };

    # Enable nix-direnv integration if requested
    programs.direnv.nix-direnv = mkIf cfg.enableNixDirenvIntegration {
      enable = true;
    };

    # Add shell aliases if specified
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (cfg.aliases // {
      da = "direnv allow";
      dr = "direnv reload";
      ds = "direnv status";
    });

    # Add useful packages for development environments
    home.packages = with pkgs; [
      # Development utilities that work well with direnv
      jq
      yq
    ] ++ mkConditionalPackages cfg.enableNixDirenvIntegration [
      nix-direnv
    ];
  };
}
