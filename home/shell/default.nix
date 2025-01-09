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
    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
  };
}
