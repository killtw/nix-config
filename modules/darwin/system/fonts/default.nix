{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.${namespace}.system.fonts;
in
{
  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;

      fonts = with pkgs; [
        (nerdfonts.override {
          fonts = [
            "SourceCodePro"
          ];
        })
      ]
      ++ cfg.fonts;
    };
  };
}
