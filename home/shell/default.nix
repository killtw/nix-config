{ pkgs, ... }: {
  home.packages = with pkgs; [
    colima
    gnupg
    google-cloud-sdk
    helmfile
    kubectl
    kubernetes-helm
    tfswitch
  ];

  imports = [
    ./alacritty.nix
    ./direnv.nix
    ./git.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  programs = {
    awscli.enable = true;
    bat.enable = true;
    eza = {
      enable = true;
      enableZshIntegration = false;
    };
    fzf = {
      enable = true;
      enableZshIntegration = false;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = false;
    };
  };
}
