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

    # Helm-diff plugin option
    enableDiffPlugin = mkBoolOpt true "Enable helm-diff plugin for comparing chart differences";

    # Helmfile integration
    enableHelmfile = mkBoolOpt true "Enable Helmfile for managing multiple Helm releases";

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

    # Helm packages and plugins using wrapHelm
    home.packages = let
      # Create wrapped helm with plugins
      wrappedHelm = if cfg.enableDiffPlugin then
        pkgs.wrapHelm (mkPackageWithFallback cfg pkgs.kubernetes-helm) {
          plugins = with pkgs.kubernetes-helmPlugins; [
            helm-diff
          ] ++ cfg.plugins;
        }
      else
        (mkPackageWithFallback cfg pkgs.kubernetes-helm);

      # Create wrapped helmfile if enabled
      wrappedHelmfile = if cfg.enableHelmfile then
        if cfg.enableDiffPlugin then
          # Use helmfile-wrapped with pluginsDir from wrapped helm
          pkgs.helmfile-wrapped.override {
            inherit (wrappedHelm) pluginsDir;
          }
        else
          pkgs.helmfile
      else null;
    in [
      wrappedHelm
    ] ++ (optionals cfg.enableHelmfile [
      wrappedHelmfile
    ]) ++ (with pkgs; [
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
    } // (mapAttrs (name: value: value) cfg.settings) // (optionalAttrs cfg.enableHelmfile {
      # Helmfile configuration
      HELMFILE_HELM3 = "1";
      HELMFILE_CACHE_HOME = "~/.cache/helmfile";
    });
  };
}
