{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    devenv
    wget
  ];

  environment.variables = {
    EDITOR = "vim";
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
