# Nix Configuration with Snowfall Lib

This repository contains my personal Nix configuration using [Snowfall Lib](https://snowfall.org/) for better organization and modularity.

## Directory Structure

```
.
├── flake.nix                    # Main flake configuration using Snowfall Lib
├── systems/                    # System configurations
│   └── aarch64-darwin/
│       ├── mini/               # Mini system configuration
│       └── longshun/           # Longshun system configuration
├── homes/                      # Home Manager configurations
│   └── aarch64-darwin/
│       ├── killtw@mini/        # Home config for killtw on mini
│       └── killtw@longshun/    # Home config for killtw on longshun
├── modules/                    # Reusable modules
│   ├── darwin/                 # Darwin-specific modules
│   │   ├── apps/               # Applications and packages
│   │   ├── core/               # Core system configuration
│   │   ├── system/             # System defaults and settings
│   │   ├── user/               # User management
│   │   └── homebrew/           # Homebrew configuration
│   └── home/                   # Home Manager modules
│       ├── shell/              # Shell configuration (programs.shell-config)
│       ├── git/                # Git configuration (programs.git-config)
│       ├── terminal/           # Terminal applications (programs.terminal-config)
│       └── user/               # User configuration (programs.user-config)
├── packages/                   # Custom packages
├── overlays/                   # Package overlays
├── lib/                        # Custom utility functions
└── shells/                     # Development environments
```

## Quick Start

### First Time Setup

1. **Clone this repository**:
   ```bash
   git clone <repository-url> ~/.config/nix
   cd ~/.config/nix
   ```

2. **Build and switch to your system**:
   ```bash
   # For mini system (requires root privileges)
   sudo darwin-rebuild switch --flake .#mini

   # For longshun system
   sudo darwin-rebuild switch --flake .#longshun
   ```

3. **Verify installation**:
   ```bash
   # Check that Home Manager is working
   which eza bat fzf zoxide

   # Check Homebrew integration
   brew list
   ```

## Usage

### Building Systems

```bash
# Build mini system (dry-run)
nix build .#darwinConfigurations.mini.system --dry-run

# Build longshun system (dry-run)
nix build .#darwinConfigurations.longshun.system --dry-run

# Actual build
nix build .#darwinConfigurations.mini.system
```

### Switching Systems

```bash
# Switch to mini configuration (requires root privileges)
sudo darwin-rebuild switch --flake .#mini

# Switch to longshun configuration
sudo darwin-rebuild switch --flake .#longshun

# Build without switching (for testing - no sudo needed)
darwin-rebuild build --flake .#mini
```

### Home Manager (Auto-integrated)

With Snowfall auto-integration, Home Manager configurations are automatically included when building Darwin systems:

```bash
# Home Manager is automatically activated with Darwin system
darwin-rebuild switch --flake .#mini

# Or build Home Manager independently
nix build .#homeConfigurations."killtw@mini".activationPackage
nix build .#homeConfigurations."killtw@longshun".activationPackage
```

### Module Configuration

Home Manager modules use the new configuration syntax:

```nix
programs = {
  shell-config.enable = true;      # Shell tools and zsh config
  git-config.enable = true;        # Git configuration
  terminal-config.enable = true;   # Terminal applications
  user-config.enable = true;       # User environment
};
```

## Configuration Guide

### Adding a New System

1. **Create system configuration**:
   ```bash
   mkdir -p systems/aarch64-darwin/newsystem
   ```

2. **Create `systems/aarch64-darwin/newsystem/default.nix`**:
   ```nix
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

3. **Create corresponding Home Manager configuration**:
   ```bash
   mkdir -p homes/aarch64-darwin/username@newsystem
   ```

4. **Create `homes/aarch64-darwin/username@newsystem/default.nix`**:
   ```nix
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

### Customizing Modules

#### Adding Homebrew Applications

Edit `modules/darwin/apps/default.nix`:

```nix
homebrew = {
  # Add command-line tools
  brews = [
    "bitwarden-cli"
    "your-new-tool"
  ];

  # Add GUI applications
  casks = [
    "existing-app"
    "your-new-app"
  ];

  # Add Mac App Store apps
  masApps = {
    "App Name" = 123456789;
  };
};
```

#### Customizing Shell Configuration

Edit `modules/home/shell/default.nix` to add your own aliases and tools:

```nix
home.packages = with pkgs; [
  bat
  eza
  fzf
  zoxide
  # Add your tools here
  your-favorite-tool
];

programs.zsh.initContent = ''
  # Existing aliases...

  # Add your custom aliases
  alias myalias="your-command"
'';
```

### Development

```bash
# Enter development shell
nix develop

# Check flake
nix flake check

# Update flake inputs
nix flake update

# Clean up old generations
sudo nix-collect-garbage -d
darwin-rebuild --rollback  # if needed
```

## Troubleshooting

### Common Issues

#### Build Failures

1. **Circular dependency errors**:
   - Ensure Home Manager modules don't use `namespace` parameter
   - Use standard `programs.*-config` paths instead

2. **Module not found**:
   ```bash
   # Ensure git changes are staged
   git add .

   # Check module recognition
   nix eval .#homeModules --apply builtins.attrNames
   ```

3. **Homebrew issues**:
   ```bash
   # Reset Homebrew if needed
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

   # Then rebuild system
   darwin-rebuild switch --flake .#mini
   ```

#### Performance Issues

1. **Slow builds**:
   ```bash
   # Use binary cache
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   cachix use nix-community

   # Enable parallel building
   echo "max-jobs = auto" >> ~/.config/nix/nix.conf
   ```

2. **Large store size**:
   ```bash
   # Regular cleanup
   nix-collect-garbage -d
   sudo nix-collect-garbage -d
   ```

### Best Practices

#### Module Development

1. **Avoid `namespace` in Home Manager modules**:
   ```nix
   # ❌ Don't do this in Home Manager modules
   { namespace, ... }: config.${namespace}.module

   # ✅ Do this instead
   { ... }: config.programs.module-config
   ```

2. **Use standard option types**:
   ```nix
   # ✅ Good
   enable = mkEnableOption "module description";

   # ✅ Good
   option = mkOption {
     type = types.str;
     default = "value";
     description = "Option description";
   };
   ```

3. **Keep modules focused**:
   - One module per logical functionality
   - Clear separation between Darwin and Home Manager modules

#### System Management

1. **Test before switching**:
   ```bash
   # Always test build first
   darwin-rebuild build --flake .#mini

   # Then switch if successful
   darwin-rebuild switch --flake .#mini
   ```

2. **Regular maintenance**:
   ```bash
   # Weekly updates
   nix flake update
   darwin-rebuild switch --flake .#mini

   # Monthly cleanup
   nix-collect-garbage -d
   sudo nix-collect-garbage -d
   ```

3. **Backup important configurations**:
   - Keep this repository in version control
   - Regular commits of working configurations
   - Tag stable releases

## Features

- **macOS Support**: Full nix-darwin integration with Apple Silicon support
- **Auto-Integration**: Darwin and Home Manager automatically integrated via Snowfall
- **Home Manager**: Dotfiles and user environment management
- **Homebrew Integration**: GUI applications via nix-homebrew with advanced features
  - Rosetta support for x86 applications
  - Automatic migration from existing Homebrew installations
  - Mutable taps support
- **Modular Design**: Clean, organized modules following Snowfall conventions
- **Multi-System**: Support for multiple machines (mini, longshun)
- **Shell Configuration**: Zsh with modern tools (eza, bat, fzf, zoxide)
- **Development Tools**: Git, terminal applications, and development environments

## Technical Details

### Snowfall Auto-Integration

This configuration leverages Snowfall's automatic integration feature:

- **Naming Convention**: `homes/aarch64-darwin/user@host/` automatically matches `systems/aarch64-darwin/host/`
- **Unified Build**: Single `darwin-rebuild` command manages both system and user configurations
- **No Circular Dependencies**: Home Manager modules use standard option paths to avoid conflicts

### Module Architecture

#### Darwin Modules (`modules/darwin/`)
- **apps**: Application installation via Homebrew
- **core**: Essential system packages and configuration
- **system**: macOS system defaults and preferences
- **user**: User account management and system-level user settings
- **homebrew**: nix-homebrew configuration with advanced features

#### Home Manager Modules (`modules/home/`)
- **shell**: Zsh configuration with modern CLI tools
- **git**: Git configuration and aliases
- **terminal**: Terminal applications (Alacritty, etc.)
- **user**: User environment and Home Manager settings

### Key Technologies

- **[Snowfall Lib](https://snowfall.org/)**: Flake organization and auto-integration
- **[nix-darwin](https://github.com/LnL7/nix-darwin)**: macOS system management
- **[Home Manager](https://github.com/nix-community/home-manager)**: User environment management
- **[nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew)**: Advanced Homebrew integration

## References

### Documentation
- [Snowfall Lib Documentation](https://snowfall.org/guides/lib/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)

### Useful Commands
```bash
# Show all available outputs
nix flake show

# Evaluate specific configuration
nix eval .#darwinConfigurations.mini.config.networking.hostName

# Check what will be built
nix build .#darwinConfigurations.mini.system --dry-run

# Show system generations
darwin-rebuild --list-generations

# Rollback to previous generation
darwin-rebuild --rollback
```

### Community Resources
- [Nix Community Discord](https://discord.gg/RbvHtGa)
- [NixOS Discourse](https://discourse.nixos.org/)
- [Awesome Nix](https://github.com/nix-community/awesome-nix)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Acknowledgments

Special thanks to the following projects and contributors that made this configuration possible:

### 🙏 **[khanelinix](https://github.com/khaneliman/khanelinix)**
This configuration was heavily inspired by and learned from the excellent khanelinix project by [@khaneliman](https://github.com/khaneliman). Key insights adopted:

- **Snowfall Auto-Integration Pattern**: The successful implementation of Darwin + Home Manager auto-integration
- **Module Architecture**: Clean separation and organization of Darwin vs Home Manager modules
- **Parameter Structure**: The simplified `{ config, lib, namespace, ... }` pattern that avoids circular dependencies
- **Configuration Conventions**: Best practices for Snowfall-based configurations

The khanelinix project served as a crucial reference for solving complex technical challenges, particularly the circular dependency issues that can arise in Snowfall auto-integration environments.

### 🛠️ **Core Technologies**
- **[Snowfall Lib](https://snowfall.org/)** - For excellent flake organization and auto-integration capabilities
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** - For comprehensive macOS system management
- **[Home Manager](https://github.com/nix-community/home-manager)** - For user environment and dotfiles management
- **[nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew)** - For advanced Homebrew integration with Rosetta support

### 🌟 **Community**
Thanks to the broader Nix community for their continuous contributions, documentation, and support that make projects like this possible.
