# Library Functions for Namespace Support

This directory contains custom library functions to support namespaced Home Manager modules and maintain backward compatibility.

## Overview

The library provides:
- **Namespace support**: Functions to create namespaced Home Manager modules
- **Common option templates**: Pre-defined option sets for different types of applications
- **Suite support**: Functions to create and manage application suites
- **Backward compatibility**: Helpers to maintain compatibility with old configuration paths
- **Utility functions**: Common patterns and helpers for module development

## File Structure

```
lib/
├── default.nix                          # Main library exports
├── home.nix                             # Home Manager specific functions
├── README.md                            # This documentation
└── examples/                            # Usage examples
    ├── terminal-app-example.nix         # Terminal application module
    ├── development-tool-example.nix     # Development tool module
    ├── suite-example.nix                # Suite module
    └── backward-compatibility-example.nix # Compatibility layer
```

## Core Functions

### Option Creation Helpers

```nix
# Basic option types
mkBoolOpt = default: description: # Boolean option
mkStrOpt = default: description:  # String option
mkIntOpt = default: description:  # Integer option
mkFloatOpt = default: description: # Float option
mkListOpt = elementType: default: description: # List option
mkAttrsOpt = default: description: # Attribute set option
mkEnumOpt = values: default: description: # Enum option

# Nullable variants
mkStrOptNull = description:  # Nullable string
mkIntOptNull = description:  # Nullable integer
mkPackageOptNull = description: # Nullable package
```

### Application-Specific Option Templates

```nix
# Terminal applications
mkTerminalOptions = appName: {
  enable = mkEnableOption "${appName} terminal application";
  package = mkPackageOptNull "Package to use";
  fontSize = mkFloatOpt 11.0 "Font size";
  fontFamily = mkStrOpt "SauceCodePro Nerd Font" "Font family";
  theme = mkEnumOpt ["dark" "light" "auto"] "dark" "Color theme";
  extraConfig = mkAttrsOpt {} "Extra configuration";
};

# Development tools
mkDevelopmentToolOptions = toolName: {
  enable = mkEnableOption "${toolName} development tool";
  package = mkPackageOptNull "Package to use";
  extraConfig = mkAttrsOpt {} "Extra configuration";
  aliases = mkAttrsOpt {} "Shell aliases";
};

# Cloud tools
mkCloudToolOptions = toolName: {
  enable = mkEnableOption "${toolName} cloud tool";
  package = mkPackageOptNull "Package to use";
  region = mkStrOptNull "Default region";
  profile = mkStrOptNull "Default profile";
  extraConfig = mkAttrsOpt {} "Extra configuration";
};

# System tools
mkSystemToolOptions = toolName: {
  enable = mkEnableOption "${toolName} system tool";
  package = mkPackageOptNull "Package to use";
  aliases = mkAttrsOpt {} "Shell aliases";
  extraConfig = mkAttrsOpt {} "Extra configuration";
};
```

### Suite Functions

```nix
# Create suite options
mkSuiteOptions = suiteName: availableModules: {
  enable = mkEnableOption "${suiteName} suite";
  modules = mkListOpt (enum availableModules) availableModules "Modules to enable";
  excludeModules = mkListOpt (enum availableModules) [] "Modules to exclude";
};

# Generate suite configuration
mkSuiteConfig = { namespace, category, cfg }:
  # Automatically enables selected modules
```

### Utility Functions

```nix
# Conditional package installation
mkConditionalPackages = condition: packages:
  if condition then packages else [];

# Package with fallback
mkPackageWithFallback = cfg: fallbackPackage:
  if cfg.package != null then cfg.package else fallbackPackage;

# Application assertions
mkAppAssertions = appName: cfg: [
  {
    assertion = cfg.enable -> (cfg.package != null || true);
    message = "${appName} is enabled but no package is available";
  }
];
```

## Usage Examples

### Creating a Terminal Application Module

```nix
# modules/home/terminal/alacritty/default.nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.terminal.alacritty;
in
{
  options.${namespace}.terminal.alacritty = mkTerminalOptions "Alacritty" // {
    # Add app-specific options
    shell = mkStrOpt "${pkgs.zsh}/bin/zsh" "Default shell";
    opacity = mkFloatOpt 1.0 "Window opacity";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "Alacritty" cfg;
    
    programs.alacritty = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.alacritty;
      settings = {
        font.size = cfg.fontSize;
        font.normal.family = cfg.fontFamily;
        window.opacity = cfg.opacity;
      } // cfg.extraConfig;
    };
  };
}
```

### Creating a Development Tool Module

```nix
# modules/home/development/git/default.nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.development.git;
in
{
  options.${namespace}.development.git = mkDevelopmentToolOptions "Git" // {
    userName = mkStrOpt "Karl Li" "Git user name";
    userEmail = mkStrOpt "killtw@gmail.com" "Git user email";
    enableDelta = mkBoolOpt true "Enable delta for diffs";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.git;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      delta.enable = cfg.enableDelta;
    };
  };
}
```

### Creating a Suite Module

```nix
# modules/home/suites/development/default.nix
{ lib, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.suites.development;
  availableModules = [ "git" "direnv" "kubectl" "helm" ];
in
{
  options.${namespace}.suites.development = mkSuiteOptions "development" availableModules;

  config = mkIf cfg.enable {
    ${namespace}.development = {
      git.enable = elem "git" cfg.modules;
      direnv.enable = elem "direnv" cfg.modules;
      kubectl.enable = elem "kubectl" cfg.modules;
      helm.enable = elem "helm" cfg.modules;
    };
  };
}
```

## Best Practices

1. **Use appropriate option templates**: Choose the right template for your application type
2. **Add application-specific options**: Extend templates with app-specific configuration
3. **Include assertions**: Use `mkAppAssertions` and add custom assertions
4. **Support package override**: Use `mkPackageWithFallback` for package options
5. **Provide sensible defaults**: Set reasonable default values for all options
6. **Document options**: Include clear descriptions for all options

## Testing

You can test the lib functions using the provided test file:

```bash
# Test basic functionality
nix-instantiate --eval lib/test.nix

# Test specific functions
nix eval .#lib --apply "lib: lib.mkTerminalOptions \"TestApp\""
nix eval .#lib --apply "lib: lib.mkBoolOpt true \"Test option\""
```

## Integration with Snowfall Lib

These functions are automatically available in all modules through the `lib.${namespace}` attribute:

```nix
# In any module
{ lib, namespace, ... }:

with lib.${namespace};  # Access custom functions

{
  options.${namespace}.myapp = mkTerminalOptions "MyApp";
}
```

## Migration Guide

When migrating from old `programs.*-config` format to namespaced modules:

1. **Keep backward compatibility**: Use the compatibility layer during transition
2. **Update gradually**: Migrate one module at a time
3. **Test thoroughly**: Ensure both old and new formats work
4. **Document changes**: Update user documentation with new paths
5. **Add deprecation warnings**: Inform users about deprecated options

## Troubleshooting

### Common Issues

1. **Function not found**: Ensure you're using `with lib.${namespace};`
2. **Type errors**: Check that option types match expected values
3. **Import errors**: Verify that lib/home.nix is properly imported

### Debug Commands

```bash
# Check if lib functions are available
nix eval .#lib --apply builtins.attrNames

# Test specific function
nix eval .#lib --apply "lib: lib.mkBoolOpt true \"test\""

# Validate module syntax
nix-instantiate --parse modules/home/category/app/default.nix
```
