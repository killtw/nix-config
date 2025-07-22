# Example: Development tool module using namespace and lib functions
# This demonstrates how to create a namespaced Home Manager module for development tools
# Location: modules/home/development/git/default.nix

{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.development.git;
in
{
  # Use the development tool options helper from lib
  options.${namespace}.development.git = mkDevelopmentToolOptions "Git" // {
    # Add Git-specific options
    userName = mkStrOpt "Karl Li" "Git user name";
    userEmail = mkStrOpt "killtw@gmail.com" "Git user email";
    
    defaultBranch = mkStrOpt "main" "Default branch name";
    
    enableLfs = mkBoolOpt true "Enable Git LFS";
    enableDelta = mkBoolOpt true "Enable delta for better diffs";
    
    extraAliases = mkAttrsOpt {} "Additional Git aliases";
    
    ignorePatterns = mkListOpt types.str [
      ".DS_Store"
      "Thumbs.db"
      ".idea"
      ".vscode"
      "*.nosync"
      ".tool-versions"
    ] "Global gitignore patterns";
    
    signingKey = mkStrOptNull "GPG key ID for commit signing";
    enableSigning = mkBoolOpt false "Enable commit signing";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Git" cfg ++ [
      {
        assertion = cfg.enableSigning -> (cfg.signingKey != null);
        message = "Git signing is enabled but no signing key is specified";
      }
    ];
    
    programs.git = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.git;
      lfs.enable = cfg.enableLfs;
      
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
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
        
        # Conditional signing configuration
      } // (optionalAttrs cfg.enableSigning {
        commit.gpgsign = true;
        user.signingkey = cfg.signingKey;
      }) // cfg.extraConfig;
      
      aliases = {
        # Common aliases
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";
        
        # Submodule aliases
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      } // cfg.extraAliases // cfg.aliases;
      
      delta = mkIf cfg.enableDelta {
        enable = true;
        options = {
          features = "side-by-side";
          syntax-theme = "Dracula";
        };
      };
      
      ignores = cfg.ignorePatterns;
    };
    
    # Add shell aliases if specified
    programs.zsh.shellAliases = cfg.aliases;
    programs.bash.shellAliases = cfg.aliases;
  };
}
