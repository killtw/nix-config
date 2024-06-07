{ inputs, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "killtw";

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };

    mutableTaps = false;
    autoMigrate = true;

    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
