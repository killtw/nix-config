{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    pkgs.devenv
    wget
  ];

  environment.variables = {
    EDITOR = "vim";
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
