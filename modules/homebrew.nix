{ inputs, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "killtw";

    taps = {};

    mutableTaps = true;
    autoMigrate = true;

    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
