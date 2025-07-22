# Example: Suite module using namespace and lib functions
# This demonstrates how to create a suite that enables multiple related modules
# Location: modules/home/suites/development/default.nix

{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;

  # Available development modules
  availableModules = [
    "git"
    "direnv"
    "kubectl"
    "helm"
  ];
in
{
  # Use the suite options helper from lib
  options.${namespace}.suites.development = mkSuiteOptions "development" availableModules // {
    # Add suite-specific options
    includeKubernetes = mkBoolOpt true "Include Kubernetes tools (kubectl, helm)";
    includeContainers = mkBoolOpt false "Include container tools (docker, podman)";

    gitConfig = {
      userName = mkStrOpt "Karl Li" "Default Git user name for development suite";
      userEmail = mkStrOpt "killtw@gmail.com" "Default Git user email for development suite";
    };

    kubernetesConfig = {
      defaultNamespace = mkStrOpt "default" "Default Kubernetes namespace";
      enableCompletion = mkBoolOpt true "Enable kubectl shell completion";
    };
  };

  config = mkIf cfg.enable {
    # Enable base development modules using lib helper
    ${namespace}.development = {
      git = {
        enable = true;
        userName = cfg.gitConfig.userName;
        userEmail = cfg.gitConfig.userEmail;
        enableDelta = true;
        extraAliases = {
          # Development-specific aliases
          dev = "checkout develop";
          main = "checkout main";
          feature = "checkout -b feature/";
          hotfix = "checkout -b hotfix/";
        };
      };

      direnv = {
        enable = true;
        extraConfig = {
          # Development suite specific direnv config
          warn_timeout = "1h";
        };
      };
    };

    # Conditionally enable Kubernetes tools
    ${namespace}.development = mkIf cfg.includeKubernetes {
      kubectl = {
        enable = true;
        extraConfig = {
          defaultNamespace = cfg.kubernetesConfig.defaultNamespace;
        };
      };

      helm = {
        enable = true;
        extraConfig = {
          # Helm-specific configuration for development
        };
      };
    };

    # Conditionally enable container tools
    ${namespace}.cloud = mkIf cfg.includeContainers {
      colima = {
        enable = true;
        extraConfig = {
          # Container runtime configuration
        };
      };
    };

    # Add development-specific packages
    home.packages = with pkgs; [
      # Version control tools
      git-lfs
      gh  # GitHub CLI

      # Development utilities
      jq
      yq
      curl
      wget

    ] ++ mkConditionalPackages cfg.includeKubernetes [
      # Kubernetes tools
      kubectx
      kubens
      k9s
    ] ++ mkConditionalPackages cfg.includeContainers [
      # Container tools
      docker-compose
    ];

    # Development-specific shell configuration
    programs.zsh = mkIf config.programs.zsh.enable {
      shellAliases = {
        # Development workflow aliases
        gs = "git status";
        gd = "git diff";
        gl = "git log --oneline -10";
        gp = "git push";
        gpu = "git pull";

        # Kubernetes aliases (if enabled)
      } // mkIf cfg.includeKubernetes {
        k = "kubectl";
        kns = "kubens";
        kctx = "kubectx";
        kgp = "kubectl get pods";
        kgs = "kubectl get services";
        kgd = "kubectl get deployments";
      };

      initContent = mkIf cfg.kubernetesConfig.enableCompletion ''
        # Kubernetes completion
        if command -v kubectl >/dev/null 2>&1; then
          source <(kubectl completion zsh)
        fi

        if command -v helm >/dev/null 2>&1; then
          source <(helm completion zsh)
        fi
      '';
    };

    # Development-specific environment variables
    home.sessionVariables = {
      EDITOR = "vim";
      PAGER = "less";

    } // mkIf cfg.includeKubernetes {
      KUBE_EDITOR = "vim";
      KUBECTL_EXTERNAL_DIFF = "diff";
    };

    # Development-specific assertions
    assertions = [
      {
        assertion = cfg.includeKubernetes -> (cfg.kubernetesConfig.defaultNamespace != "");
        message = "Kubernetes tools are enabled but no default namespace is specified";
      }
    ];
  };
}
