# Snowfall Nix Configuration Usage Guide

This guide provides detailed instructions for using and customizing this Snowfall-based Nix configuration.

## Table of Contents

- [Installation](#installation)
- [Daily Usage](#daily-usage)
- [Customization](#customization)
- [Module Development](#module-development)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

## Installation

### Prerequisites

1. **Install Nix with flakes support**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Install nix-darwin**:
   ```bash
   nix run nix-darwin -- switch --flake github:LnL7/nix-darwin#simple
   ```

### Initial Setup

1. **Clone this configuration**:
   ```bash
   git clone <repository-url> ~/.config/nix
   cd ~/.config/nix
   ```

2. **Customize for your system**:
   - Edit `systems/aarch64-darwin/mini/default.nix` (or create your own)
   - Update user information, hostname, etc.

3. **Apply configuration**:
   ```bash
   # Note: System activation requires root privileges
   sudo darwin-rebuild switch --flake .#mini
   ```

## Daily Usage

### System Updates

```bash
# Update flake inputs
nix flake update

# Rebuild and switch (requires root privileges)
sudo darwin-rebuild switch --flake .#mini

# Or build first to test
darwin-rebuild build --flake .#mini
```

### Package Management

#### System Packages (via modules)
Edit `modules/darwin/apps/default.nix`:
```nix
homebrew = {
  brews = [
    "existing-tool"
    "new-tool"  # Add here
  ];
  
  casks = [
    "existing-app"
    "new-app"   # Add here
  ];
};
```

#### User Packages (via Home Manager)
Edit `modules/home/shell/default.nix`:
```nix
home.packages = with pkgs; [
  bat
  eza
  your-new-package  # Add here
];
```

### Environment Management

#### Shell Aliases
Edit `modules/home/shell/default.nix`:
```nix
programs.zsh.initContent = ''
  # Existing aliases...
  
  # Your custom aliases
  alias ll="eza -la"
  alias myproject="cd ~/Projects/myproject"
'';
```

#### Git Configuration
Edit `modules/home/git/default.nix`:
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  
  aliases = {
    st = "status";
    co = "checkout";
    # Add your aliases
  };
};
```

## Customization

### Adding a New System

1. **Create system directory**:
   ```bash
   mkdir -p systems/aarch64-darwin/newsystem
   ```

2. **Create system configuration**:
   ```nix
   # systems/aarch64-darwin/newsystem/default.nix
   { lib, namespace, ... }:
   {
     ${namespace} = {
       apps.enable = true;
       core.enable = true;
       system.enable = true;
       
       user = {
         name = "username";
         email = "user@example.com";
         fullName = "Full Name";
         uid = 501;
         hostname = "newsystem";
       };
       
       homebrew = {
         enable = true;
         username = "username";
       };
     };
   }
   ```

3. **Create Home Manager configuration**:
   ```bash
   mkdir -p homes/aarch64-darwin/username@newsystem
   ```

   ```nix
   # homes/aarch64-darwin/username@newsystem/default.nix
   { config, lib, ... }:
   {
     programs = {
       shell-config.enable = true;
       git-config.enable = true;
       terminal-config.enable = true;
       user-config.enable = true;
     };

     home.stateVersion = "24.05";
   }
   ```

4. **Build and switch**:
   ```bash
   sudo darwin-rebuild switch --flake .#newsystem
   ```

### Customizing Existing Modules

#### Shell Module
Location: `modules/home/shell/default.nix`

Add tools:
```nix
home.packages = with pkgs; [
  # Existing tools
  bat eza fzf zoxide
  
  # Your additions
  ripgrep
  fd
  tree
];
```

Add aliases:
```nix
programs.zsh.initContent = ''
  # Custom aliases
  alias grep="rg"
  alias find="fd"
'';
```

#### Homebrew Module
Location: `modules/darwin/apps/default.nix`

Add applications:
```nix
homebrew = {
  brews = [
    "bitwarden-cli"
    "your-cli-tool"
  ];
  
  casks = [
    "visual-studio-code"
    "your-gui-app"
  ];
  
  masApps = {
    "Your App" = 123456789;
  };
};
```

## Module Development

### Creating a New Home Manager Module

1. **Create module directory**:
   ```bash
   mkdir -p modules/home/mymodule
   ```

2. **Create module file**:
   ```nix
   # modules/home/mymodule/default.nix
   { lib, pkgs, config, ... }:

   with lib;

   let
     cfg = config.programs.mymodule-config;
   in
   {
     options.programs.mymodule-config = {
       enable = mkEnableOption "my custom module";
       
       setting = mkOption {
         type = types.str;
         default = "default-value";
         description = "A custom setting";
       };
     };

     config = mkIf cfg.enable {
       home.packages = with pkgs; [
         # Your packages
       ];
       
       # Your configuration
     };
   }
   ```

3. **Use in Home Manager configuration**:
   ```nix
   programs.mymodule-config = {
     enable = true;
     setting = "custom-value";
   };
   ```

### Creating a New Darwin Module

1. **Create module directory**:
   ```bash
   mkdir -p modules/darwin/mymodule
   ```

2. **Create module file**:
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
       enable = mkBoolOpt false "Enable my custom module";
     };

     config = mkIf cfg.enable {
       # Your Darwin-specific configuration
     };
   }
   ```

3. **Use in system configuration**:
   ```nix
   ${namespace} = {
     mymodule.enable = true;
   };
   ```

## Troubleshooting

### Common Issues

#### "Module not found" errors
```bash
# Ensure changes are staged in git
git add .

# Check module recognition
nix eval .#homeModules --apply builtins.attrNames
nix eval .#darwinModules --apply builtins.attrNames
```

#### Circular dependency errors
- Avoid using `namespace` parameter in Home Manager modules
- Use standard `config.programs.*` paths instead

#### Build failures
```bash
# Clean build
nix-collect-garbage -d
sudo nix-collect-garbage -d

# Rebuild
sudo darwin-rebuild switch --flake .#mini
```

### Getting Help

1. **Check logs**:
   ```bash
   # Darwin rebuild logs
   sudo darwin-rebuild switch --flake .#mini --show-trace
   
   # Nix build logs
   nix build .#darwinConfigurations.mini.system --show-trace
   ```

2. **Validate configuration**:
   ```bash
   nix flake check
   ```

3. **Community resources**:
   - [NixOS Discourse](https://discourse.nixos.org/)
   - [Nix Community Discord](https://discord.gg/RbvHtGa)

## Advanced Topics

### Performance Optimization

1. **Enable binary caches**:
   ```bash
   # Add to nix.conf
   substituters = https://cache.nixos.org/ https://nix-community.cachix.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

2. **Parallel builds**:
   ```bash
   # Add to nix.conf
   max-jobs = auto
   cores = 0
   ```

### Backup and Recovery

1. **Backup configuration**:
   ```bash
   # This repository IS your backup
   git push origin main
   ```

2. **System recovery**:
   ```bash
   # Rollback to previous generation
   darwin-rebuild --rollback
   
   # List generations
   darwin-rebuild --list-generations
   
   # Switch to specific generation
   darwin-rebuild --switch-generation 42
   ```

### Integration with Other Tools

#### VS Code
The configuration includes VS Code via Homebrew. For Nix integration:
```bash
# Install Nix extension
code --install-extension bbenoist.Nix
```

#### Development Environments
Use `nix develop` for project-specific environments:
```nix
# flake.nix in your project
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  
  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs
          python3
          # project dependencies
        ];
      };
    };
}
```
