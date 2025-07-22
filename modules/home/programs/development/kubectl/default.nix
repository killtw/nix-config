# Kubectl Kubernetes CLI module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.kubectl;
in
{
  options.${namespace}.programs.development.kubectl = mkDevelopmentToolOptions "Kubectl" // {
    # Kubectl-specific options
    defaultNamespace = mkStrOpt "default" "Default Kubernetes namespace";

    enableKubectx = mkBoolOpt true "Enable kubectx for context switching";
    enableKubens = mkBoolOpt true "Enable kubens for namespace switching";

    plugins = mkListOpt types.package [] "Kubectl plugins to install";

    kubeconfig = mkStrOptNull "Path to kubeconfig file";

    contexts = mkListOpt (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Context name";
        };
        cluster = mkOption {
          type = types.str;
          description = "Cluster name";
        };
        user = mkOption {
          type = types.str;
          description = "User name";
        };
        namespace = mkOption {
          type = types.str;
          default = "default";
          description = "Default namespace for this context";
        };
      };
    }) [] "Predefined kubectl contexts";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Kubectl" cfg ++ [
      {
        assertion = cfg.defaultNamespace != "";
        message = "Default Kubernetes namespace cannot be empty";
      }
      {
        assertion = all (ctx: ctx.name != "" && ctx.cluster != "" && ctx.user != "") cfg.contexts;
        message = "All kubectl contexts must have non-empty name, cluster, and user";
      }
    ];

    # Kubectl packages and plugins
    home.packages = [
      (mkPackageWithFallback cfg pkgs.kubectl)
    ] ++ cfg.plugins
      ++ mkConditionalPackages cfg.enableKubectx [ pkgs.kubectx ]
      ++ mkConditionalPackages cfg.enableKubens [ pkgs.kubectx ]  # kubens is part of kubectx package
      ++ (with pkgs; [
        # YAML processing tools
        yq
        # JSON processing
        jq
      ]);

    # Environment variables
    home.sessionVariables = {
      KUBE_EDITOR = "vim";
      KUBECTL_EXTERNAL_DIFF = "diff";
    } // (optionalAttrs (cfg.kubeconfig != null) {
      KUBECONFIG = cfg.kubeconfig;
    });


  };
}
