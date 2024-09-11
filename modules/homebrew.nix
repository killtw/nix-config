{ inputs, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "killtw";

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "hashicorp/tap" = inputs.homebrew-hashicorp;
    };

    mutableTaps = true;
    autoMigrate = true;

    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
