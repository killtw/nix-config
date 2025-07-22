# Development Suite - A comprehensive development environment
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;

  # Available development modules
  availableModules = [
    "kubectl"
    "helm"
    "awscli"
    "gcp"
    "colima"
  ];
in
{
  # Use the suite options helper from lib
  options.${namespace}.suites.development = mkSuiteOptions "development" availableModules;
  config = mkIf cfg.enable {
    # Enable development modules with default settings
    ${namespace}.programs = {
      development = {
        kubectl = mkIf (elem "kubectl" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        helm = mkIf (elem "helm" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };

      cloud = {
        awscli = mkIf (elem "awscli" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        gcp = mkIf (elem "gcp" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };

        colima = mkIf (elem "colima" (subtractLists cfg.excludeModules cfg.modules)) {
          enable = true;
        };
      };
    };
  };
}
