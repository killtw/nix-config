{ inputs, username, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;

    mutableTaps = true;
    autoMigrate = true;
  };
}
