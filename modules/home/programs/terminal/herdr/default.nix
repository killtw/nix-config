# Tmux terminal multiplexer module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.herdr;
in
{
  options.${namespace}.programs.terminal.herdr = mkTerminalOptions "Herdr";

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Herdr" cfg;

    programs.herdr = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.herdr;

      settings = {
        onboarding = false;

        theme.name = "terminal";

        keys = {
          prefix = "ctrl+b";

          indexed = {
            workspaces = "ctrl+shift";
            tabs = "alt";
          };

          command = [
            {
              key = "prefix+f";
              type = "plugin_action";
              command = "herdr-file-viewer.open-file-viewer";
              description = "open file viewer in split";
            }
            {
              key = "prefix+shift+f";
              type = "plugin_action";
              command = "herdr-file-viewer.open-file-viewer-tab";
              description = "open file viewer in tab";
            }
          ];
        };
      };
    };
  };
}
