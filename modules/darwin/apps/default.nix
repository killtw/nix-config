# Darwin applications and packages module
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.apps;
in
{
  options.${namespace}.apps = {
    enable = mkBoolOpt false "Whether to enable applications configuration.";
  };

  config = {
    environment = {
      variables = {
        EDITOR = "vim";
        HOMEBREW_NO_ANALYTICS = "1";
      };
    };

    homebrew = {
      enable = true;

      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
      };
    };
  };

}
