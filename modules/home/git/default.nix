# Home Manager Git configuration module
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.git-config;
in
{
  options.programs.git-config = {
    enable = mkEnableOption "Git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      userName = "Karl Li";
      userEmail = "killtw@gmail.com";

      extraConfig = {
        branch.sort = "-committerdate";
        column.ui = "auto";
        commit.verbose = true;
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        tag.sort = "version:refname";
      };

      aliases = {
        # common aliases
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";

        # aliases for submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };

      delta = {
        enable = true;
        options = {
          features = "side-by-side";
        };
      };

      ignores = [
        ".DS_Store"
        "Thumbs.db"
        ".idea"
        "composer.phar"
        ".vscode"
        "*.nosync"
        ".tool-versions"
      ];
    };
  };
}
