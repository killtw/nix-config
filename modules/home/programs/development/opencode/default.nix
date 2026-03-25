# OpenCode - Open source AI coding agent module with namespace support
# Package installed via Homebrew (Darwin suite), this module manages config and env vars
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.opencode;
in
{
  options.${namespace}.programs.development.opencode = mkDevelopmentToolOptions "OpenCode" // {
    # OpenCode specific options
    enableAutoUpdater = mkBoolOpt false "Enable OpenCode auto updater (disabled by default for Nix)";

    configDir = mkStrOpt "~/.opencode" "Directory for OpenCode configuration";

    # Environment variables
    environmentVariables = mkAttrsOpt {} "Additional environment variables for OpenCode";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "OpenCode" cfg ++ [
      {
        assertion = cfg.configDir != "";
        message = "OpenCode config directory cannot be empty";
      }
    ];

    # Environment variables
    home.sessionVariables = {
      DISABLE_AUTOUPDATER = if cfg.enableAutoUpdater then "0" else "1";
    } // cfg.environmentVariables;

    # Shell aliases from config
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable (
      { opencode-update = "brew upgrade opencode"; }
      // cfg.aliases
    );

    programs.bash.shellAliases = mkIf config.programs.bash.enable (
      { opencode-update = "brew upgrade opencode"; }
      // cfg.aliases
    );

    programs.fish.shellAliases = mkIf config.programs.fish.enable (
      { opencode-update = "brew upgrade opencode"; }
      // cfg.aliases
    );
  };
}
