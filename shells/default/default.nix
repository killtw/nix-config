# Default development shell
{ pkgs, ... }:

pkgs.mkShell {
  name = "nix-config-dev";
  
  buildInputs = with pkgs; [
    # Development tools
    git
    nixfmt-rfc-style
    statix
    deadnix
  ];

  shellHook = ''
    echo "Welcome to nix-config development environment!"
    echo "Available tools: git, nixfmt-rfc-style, statix, deadnix"
  '';
}
