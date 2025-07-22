# Helm Kubernetes package manager module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.development.helm;
in
{
  options.${namespace}.programs.development.helm = mkDevelopmentToolOptions "Helm" // {
    # Helm-specific options
    enableCompletion = mkBoolOpt true "Enable shell completion";

    repositories = mkListOpt (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Repository name";
        };
        url = mkOption {
          type = types.str;
          description = "Repository URL";
        };
      };
    }) [
      { name = "stable"; url = "https://charts.helm.sh/stable"; }
      { name = "bitnami"; url = "https://charts.bitnami.com/bitnami"; }
    ] "Helm chart repositories";

    plugins = mkListOpt types.package [] "Helm plugins to install";

    settings = mkAttrsOpt {
      repositoryConfig = "~/.config/helm/repositories.yaml";
      repositoryCache = "~/.cache/helm/repository";
      pluginsDirectory = "~/.local/share/helm/plugins";
      registryConfig = "~/.config/helm/registry/config.json";
      registryCache = "~/.cache/helm/registry";
    } "Helm configuration settings";
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Helm" cfg ++ [
      {
        assertion = all (repo: repo.name != "" && repo.url != "") cfg.repositories;
        message = "All Helm repositories must have non-empty name and url";
      }
    ];

    # Helm packages and plugins
    home.packages = [
      (mkPackageWithFallback cfg pkgs.kubernetes-helm)
    ] ++ cfg.plugins ++ (with pkgs; [
      # YAML processing tools
      yq
      # JSON processing
      jq
    ]);

    # Helm configuration
    home.file.".config/helm/repositories.yaml" = mkIf (cfg.repositories != []) {
      text = ''
        apiVersion: ""
        generated: "2024-01-01T00:00:00Z"
        repositories:
        ${concatMapStringsSep "\n" (repo: ''
          - name: ${repo.name}
            url: ${repo.url}
        '') cfg.repositories}
      '';
    };

    # Environment variables
    home.sessionVariables = {
      HELM_CONFIG_HOME = "~/.config/helm";
      HELM_CACHE_HOME = "~/.cache/helm";
      HELM_DATA_HOME = "~/.local/share/helm";
    } // (mapAttrs (name: value: value) cfg.settings);
  };
}
