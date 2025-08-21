# Home Manager specific library functions
{ lib, ... }:

with lib;

{
  # Common options for terminal applications
  mkTerminalOptions = appName: {
    enable = lib.mkEnableOption "${appName} terminal application";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Package to use for ${appName}. If null, uses the default from nixpkgs.";
    };

    fontSize = lib.mkOption {
      type = lib.types.float;
      default = 11.0;
      description = "Font size for ${appName}";
    };

    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "SauceCodePro Nerd Font";
      description = "Font family for ${appName}";
    };

    theme = lib.mkOption {
      type = lib.types.enum [ "dark" "light" "auto" ];
      default = "dark";
      description = "Color theme for ${appName}";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration options for ${appName}";
    };
  };

  # Common options for development tools
  mkDevelopmentToolOptions = toolName: {
    enable = lib.mkEnableOption "${toolName} development tool";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Package to use for ${toolName}. If null, uses the default from nixpkgs.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration for ${toolName}";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases for ${toolName}";
    };
  };

  # Common options for cloud tools
  mkCloudToolOptions = toolName: {
    enable = lib.mkEnableOption "${toolName} cloud tool";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Package to use for ${toolName}. If null, uses the default from nixpkgs.";
    };

    region = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default region for ${toolName}";
    };

    profile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default profile for ${toolName}";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration for ${toolName}";
    };
  };

  # Common options for system tools
  mkSystemToolOptions = toolName: {
    enable = lib.mkEnableOption "${toolName} system tool";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Package to use for ${toolName}. If null, uses the default from nixpkgs.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases for ${toolName}";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration for ${toolName}";
    };
  };

  # Suite options template
  mkSuiteOptions = suiteName: availableModules: {
    enable = lib.mkEnableOption "${suiteName} suite";

    modules = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableModules);
      default = availableModules;
      description = "List of modules to enable in the ${suiteName} suite";
    };

    excludeModules = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableModules);
      default = [];
      description = "List of modules to exclude from the ${suiteName} suite";
    };
  };

  # Helper to create conditional package installation
  mkConditionalPackages = condition: packages:
    if condition then packages else [];

  # Helper to create application assertions
  mkAppAssertions = appName: cfg: [
    {
      assertion = cfg.enable -> (cfg.package != null || true);
      message = "${appName} is enabled but no package is available";
    }
  ];

  # Helper to get package with fallback
  mkPackageWithFallback = cfg: fallbackPackage:
    if cfg.package != null then cfg.package else fallbackPackage;


}
