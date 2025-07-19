# Darwin Homebrew configuration module
{ lib, pkgs, config, namespace, inputs, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.homebrew;
in
{
  options.${namespace}.homebrew = {
    enable = mkBoolOpt false "Whether to enable Homebrew configuration.";
    username = mkStrOpt "killtw" "The username for nix-homebrew.";
  };

  config = mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = cfg.username;

      mutableTaps = true;
      autoMigrate = true;
    };

    # 設定 homebrew 環境變數
    environment.variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_AUTO_UPDATE = "1";
    };
  };
}
