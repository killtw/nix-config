# Module Development Guide

This guide explains how to develop and maintain modules for this Snowfall-based Nix configuration.

## Table of Contents

- [Module Architecture](#module-architecture)
- [Home Manager Modules](#home-manager-modules)
- [Darwin Modules](#darwin-modules)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Common Patterns](#common-patterns)

## Module Architecture

### Directory Structure

```
modules/
├── darwin/                 # System-level modules
│   ├── apps/              # Application management
│   ├── core/              # Core system configuration
│   ├── system/            # System defaults
│   ├── user/              # User management
│   └── homebrew/          # Homebrew configuration
└── home/                  # User-level modules
    ├── shell/             # Shell configuration
    ├── git/               # Git configuration
    ├── terminal/          # Terminal applications
    └── user/              # User environment
```

### Module Types

#### Darwin Modules
- **Purpose**: System-level configuration
- **Scope**: Affects entire system
- **Examples**: System preferences, global packages, user accounts
- **Can use**: `namespace` parameter safely

#### Home Manager Modules
- **Purpose**: User-level configuration
- **Scope**: Affects specific user environment
- **Examples**: Dotfiles, user packages, shell configuration
- **Cannot use**: `namespace` parameter (causes circular dependencies)

## Home Manager Modules

### Template

```nix
# modules/home/mymodule/default.nix
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.mymodule-config;
in
{
  options.programs.mymodule-config = {
    enable = mkEnableOption "my module description";
    
    setting = mkOption {
      type = types.str;
      default = "default-value";
      description = "Description of the setting";
    };
    
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Default packages
      essential-tool
    ] ++ cfg.packages;
    
    # Configuration files
    home.file.".myconfig".text = ''
      setting=${cfg.setting}
    '';
    
    # Program configuration
    programs.myprogram = {
      enable = true;
      settings = {
        key = cfg.setting;
      };
    };
  };
}
```

### Key Points

1. **Option Path**: Use `config.programs.modulename-config`
2. **No Namespace**: Don't use `namespace` parameter
3. **Standard Functions**: Use `mkEnableOption`, `mkOption`
4. **Conditional Config**: Use `mkIf cfg.enable`

### Example: Shell Module

```nix
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.shell-config;
in
{
  options.programs.shell-config = {
    enable = mkEnableOption "shell configuration";
    
    extraAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional shell aliases";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      eza
      fzf
      zoxide
    ];

    programs = {
      bat.enable = true;
      eza.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      
      zsh = {
        enable = true;
        autocd = true;
        
        initContent = ''
          # Basic aliases
          alias ls="eza --icons --group-directories-first"
          alias ll="eza --icons --group-directories-first -l"
          alias cat="bat"
          
          # User aliases
          ${concatStringsSep "\n" (mapAttrsToList (k: v: "alias ${k}=\"${v}\"") cfg.extraAliases)}
        '';
        
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      };
    };
  };
}
```

## Darwin Modules

### Template

```nix
# modules/darwin/mymodule/default.nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.mymodule;
in
{
  options.${namespace}.mymodule = {
    enable = mkBoolOpt false "Enable my module";
    
    setting = mkStrOpt "default" "Module setting";
  };

  config = mkIf cfg.enable {
    # System configuration
    system.defaults.NSGlobalDomain.setting = cfg.setting;
    
    # System packages
    environment.systemPackages = with pkgs; [
      system-tool
    ];
    
    # Services
    services.myservice = {
      enable = true;
      config = cfg.setting;
    };
  };
}
```

### Key Points

1. **Option Path**: Use `config.${namespace}.modulename`
2. **Namespace Safe**: Can use `namespace` parameter
3. **Helper Functions**: Use `mkBoolOpt`, `mkStrOpt` from lib
4. **System Scope**: Configure system-wide settings

### Example: User Module

```nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = {
    name = mkStrOpt "killtw" "The user account.";
    email = mkStrOpt "killtw@gmail.com" "The email of the user.";
    fullName = mkStrOpt "Karl Li" "The full name of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
    hostname = mkStrOpt "mini" "The hostname for this system.";
  };

  config = {
    networking.hostName = cfg.hostname;
    networking.computerName = cfg.hostname;
    system.defaults.smb.NetBIOSName = cfg.hostname;

    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
      home = "/Users/${cfg.name}";
      description = cfg.fullName;
      shell = pkgs.zsh;
    };

    nix.settings.trusted-users = ["@admin" cfg.name];
  };
}
```

## Best Practices

### 1. Module Design

#### Single Responsibility
```nix
# ✅ Good - focused module
modules/home/git/default.nix     # Only Git configuration

# ❌ Bad - too broad
modules/home/development/default.nix  # Git + editors + tools
```

#### Clear Options
```nix
# ✅ Good - clear, typed options
options.programs.git-config = {
  enable = mkEnableOption "Git configuration";
  userName = mkOption {
    type = types.str;
    description = "Git user name";
  };
};

# ❌ Bad - unclear options
options.git = {
  stuff = mkOption { type = types.attrs; };
};
```

### 2. Error Handling

#### Assertions
```nix
config = mkIf cfg.enable {
  assertions = [
    {
      assertion = cfg.userName != "";
      message = "Git user name cannot be empty";
    }
  ];
  
  # Rest of config...
};
```

#### Default Values
```nix
# ✅ Good - sensible defaults
setting = mkOption {
  type = types.str;
  default = "reasonable-default";
  description = "Setting description";
};

# ❌ Bad - no default for required setting
setting = mkOption {
  type = types.str;
  description = "Required setting";
};
```

### 3. Documentation

#### Option Descriptions
```nix
# ✅ Good - clear description
enable = mkEnableOption "shell configuration with modern CLI tools";

setting = mkOption {
  type = types.str;
  default = "default-value";
  description = ''
    This setting controls the behavior of the module.
    
    Possible values:
    - "option1": Does this
    - "option2": Does that
  '';
};
```

#### Module Comments
```nix
# Home Manager shell configuration module
# 
# This module provides:
# - Modern CLI tools (bat, eza, fzf, zoxide)
# - Zsh configuration with useful aliases
# - Syntax highlighting and autosuggestions
{ lib, pkgs, config, ... }:
```

## Testing

### 1. Syntax Validation

```bash
# Check Nix syntax
nix-instantiate --parse modules/home/mymodule/default.nix

# Check flake
nix flake check
```

### 2. Module Recognition

```bash
# Check if module is recognized
nix eval .#homeModules --apply builtins.attrNames
nix eval .#darwinModules --apply builtins.attrNames
```

### 3. Build Testing

```bash
# Test Home Manager module
nix build .#homeConfigurations."killtw@mini".activationPackage --dry-run

# Test Darwin module
nix build .#darwinConfigurations.mini.system --dry-run
```

### 4. Integration Testing

```bash
# Test actual build
darwin-rebuild build --flake .#mini

# Test switch (if build succeeds)
darwin-rebuild switch --flake .#mini
```

## Common Patterns

### 1. Conditional Package Installation

```nix
config = mkIf cfg.enable {
  home.packages = with pkgs; [
    essential-package
  ] ++ optionals cfg.enableOptionalFeature [
    optional-package
  ] ++ cfg.extraPackages;
};
```

### 2. File Generation

```nix
config = mkIf cfg.enable {
  home.file = {
    ".myconfig".text = ''
      # Generated configuration
      setting1=${cfg.setting1}
      setting2=${cfg.setting2}
    '';
    
    ".myconfig.json".source = pkgs.writeText "myconfig.json" (builtins.toJSON {
      setting1 = cfg.setting1;
      setting2 = cfg.setting2;
    });
  };
};
```

### 3. Program Configuration

```nix
config = mkIf cfg.enable {
  programs.myprogram = {
    enable = true;
    settings = {
      key1 = cfg.setting1;
      key2 = cfg.setting2;
    } // cfg.extraSettings;
  };
};
```

### 4. Service Management (Darwin)

```nix
config = mkIf cfg.enable {
  launchd.user.agents.myservice = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.myprogram}/bin/myprogram" ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
};
```

### 5. System Defaults (Darwin)

```nix
config = mkIf cfg.enable {
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    
    dock = {
      autohide = true;
      orientation = "bottom";
    };
  };
};
```

## Debugging

### 1. Trace Values

```nix
config = mkIf cfg.enable {
  # Debug option values
  home.file.".debug".text = builtins.trace "cfg.setting: ${cfg.setting}" ''
    Debug info: ${cfg.setting}
  '';
};
```

### 2. Show Trace

```bash
# Show detailed error traces
nix build .#homeConfigurations."killtw@mini".activationPackage --show-trace
```

### 3. Evaluate Options

```bash
# Check option values
nix eval .#homeConfigurations."killtw@mini".config.programs.shell-config.enable
```

This guide should help you develop robust, maintainable modules for your Snowfall configuration!
