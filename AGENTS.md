# AGENTS.md

Instructions for AI agents working on this Nix configuration repository.

## Project Overview

- **Framework**: Snowfall Lib for macOS (Darwin) + Home Manager
- **Namespace**: `killtw`
- **Target**: aarch64-darwin

## Build & Test Commands

```bash
# Syntax check (ALWAYS run first)
nix-instantiate --parse path/to/file.nix

# Test Darwin build
nix build --dry-run .#darwinConfigurations.hostname.system

# Apply Darwin config
sudo darwin-rebuild switch --flake .#hostname

# Test Home Manager build
nix build --dry-run .#homeConfigurations.user@host.activationPackage

# Apply Home Manager config
home-manager switch --flake .#user@host

# Debug with trace
nix build --show-trace .#darwinConfigurations.hostname.system

# List modules
nix eval .#darwinModules --apply builtins.attrNames
nix eval .#homeModules --apply builtins.attrNames
```

## Code Style

### Formatting
- **Indentation**: 2 spaces for `.nix` files
- **Line endings**: LF, UTF-8, final newline required

### Module Template (Darwin)

```nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.path.to.module;
in
{
  options.${namespace}.path.to.module = {
    enable = mkEnableOption "description";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "ModuleName" cfg;
    # configuration here
  };
}
```

### Module Template (Home Manager)
**CRITICAL**: Do NOT use `namespace` parameter - causes circular dependencies.

```nix
{ lib, pkgs, config, ... }:  # NO namespace here!

with lib;

let
  cfg = config.programs.mymodule-config;
in
{
  options.programs.mymodule-config = {
    enable = mkEnableOption "description";
  };

  config = mkIf cfg.enable { };
}
```

### Option Helpers (from `lib.${namespace}`)

| Helper | Usage |
|--------|-------|
| `mkBoolOpt default desc` | Boolean option |
| `mkStrOpt default desc` | String option |
| `mkStrOptNull desc` | Nullable string |
| `mkIntOpt default desc` | Integer option |
| `mkListOpt type default desc` | List option |
| `mkAttrsOpt default desc` | Attrs option |
| `mkPackageOptNull desc` | Nullable package |
| `mkEnumOpt values default desc` | Enum option |

### Pre-defined Templates

```nix
mkTerminalOptions "AppName"          # Terminal apps
mkDevelopmentToolOptions "ToolName"  # Dev tools
mkSystemToolOptions "ToolName"       # System tools
mkCloudToolOptions "ToolName"        # Cloud tools
mkDarwinSuiteOptions "name" modules  # Darwin suites
```

### Naming Conventions
- Module paths: lowercase, hyphen-separated (`programs.development.git`)
- Option names: camelCase (`userName`, `enableDelta`)
- Suite modules list: hyphen-separated strings (`["bitwarden-cli" "raycast"]`)

## Directory Structure

```
modules/
├── darwin/           # System-level (CAN use namespace)
│   ├── core/
│   ├── homebrew/
│   ├── suites/       # common, development, system, media...
│   └── user/
└── home/             # User-level (NO namespace param!)
    ├── programs/
    │   ├── cloud/    # aws, gcp, colima
    │   ├── development/  # git, direnv, kubectl
    │   ├── shell/    # zsh
    │   ├── system/   # bat, eza, fzf, starship, zoxide
    │   └── terminal/ # alacritty, tmux
    ├── suites/
    └── user/
```

## Important Rules

### DO
- Run `git add .` before testing (Snowfall requires tracked files)
- Test with `nix build --dry-run` before applying
- Use `mkPackageWithFallback cfg pkgs.default` for packages
- Include assertions for required options

### DO NOT
- Use `namespace` in Home Manager modules
- Skip syntax validation
- Hard-code configurable values
- Mix Darwin suites with manual Homebrew config

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Module not recognized | `git add .` |
| Silent build failure | Add `--show-trace` |
| Syntax errors | `nix-instantiate --parse file.nix` |
| Circular dependency | Remove `namespace` from Home Manager params |

## Quick Workflow

```bash
nix-instantiate --parse modules/path/default.nix  # 1. Syntax
git add .                                          # 2. Track
nix build --dry-run .#darwinConfigurations.mini.system  # 3. Test
sudo darwin-rebuild switch --flake .#mini          # 4. Apply
```
