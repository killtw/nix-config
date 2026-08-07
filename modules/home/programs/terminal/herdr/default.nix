# Tmux terminal multiplexer module with namespace support
{ lib, pkgs, config, namespace, darwinConfig ? null, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.terminal.herdr;
  homebrewPrefix =
    if darwinConfig != null then
      darwinConfig.homebrew.prefix
    else if pkgs.stdenv.hostPlatform.isAarch64 then
      "/opt/homebrew"
    else
      "/usr/local";
  herdrHomebrewBin = "${homebrewPrefix}/bin/herdr";
  tomlFormat = pkgs.formats.toml { };
in
{
  options.${namespace}.programs.terminal.herdr = mkTerminalOptions "Herdr";

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Herdr" cfg;

    programs.herdr = {
      enable = true;
      package = null;

      settings = {
        onboarding = false;

        theme.name = "terminal";

        ui = {
          toast.delivery = "herdr";
          sound.enabled = true;
        };

        experimental = {
          kitty_graphics = true;
        };

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
            {
              key = "cmd+r";
              type = "plugin_action";
              command = "persiyanov.reviewr.toggle";
            }
          ];
        };
      };
    };

    # Home Manager uses the bare `herdr` command when package = null, but
    # activation does not necessarily include Homebrew's bin directory.
    xdg.configFile."herdr/config.toml".onChange = mkForce ''
      if [ -x "${herdrHomebrewBin}" ]; then
        "${herdrHomebrewBin}" server reload-config || true
      else
        echo "warning: Homebrew Herdr executable not found at ${herdrHomebrewBin}; skipping config reload" >&2
      fi
    '';

    xdg.configFile."herdr/plugins/config/persiyanov.reviewr/config.toml" = {
      source = tomlFormat.generate "herdr-reviewer-config.toml" {
        theme = "nord";
        toggle_direction = "down";
      };
    };
  };
}
