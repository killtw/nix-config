# AGENTS.md

Instructions for AI agents working on this Nix configuration repository.

## Project Overview

- **Framework**: Snowfall Lib for macOS (Darwin) + Home Manager
- **Namespace**: `killtw`
- **Target**: aarch64-darwin (Apple Silicon)
- **Hosts**: mini, m4, longshun

## Build & Test Commands

```bash
# ALWAYS run syntax check first
nix-instantiate --parse path/to/file.nix

# Test Darwin build (dry-run)
nix build --dry-run .#darwinConfigurations.mini.system

# Apply Darwin config
sudo darwin-rebuild switch --flake .#mini

# Test Home Manager build (dry-run)
nix build --dry-run .#homeConfigurations."killtw@mini".activationPackage

# Apply Home Manager config
home-manager switch --flake .#killtw@mini

# Debug with trace
nix build --show-trace .#darwinConfigurations.mini.system

# List available modules
nix eval .#darwinModules --apply builtins.attrNames
nix eval .#homeModules --apply builtins.attrNames

# Validate lib functions
nix eval .#lib --apply "lib: lib.mkBoolOpt true \"test\""
```

## Code Style

### Formatting
- **Indentation**: 2 spaces
- **Line endings**: LF, UTF-8
- **Final newline**: Required

### Darwin Module Template

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

### Home Manager Module Template

```nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.category.modulename;
in
{
  options.${namespace}.programs.category.modulename = mkSystemToolOptions "ToolName" // {
    # Tool-specific options
    customOption = mkBoolOpt true "Description";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "ToolName" cfg;
    
    programs.toolname = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.toolname;
    };
  };
}
```

### Option Helpers (from `lib.${namespace}`)

| Helper | Usage |
|--------|-------|
| `mkBoolOpt default desc` | Boolean option |
| `mkStrOpt default desc` | String option |
| `mkStrOptNull desc` | Nullable string |
| `mkIntOpt default desc` | Integer option |
| `mkIntOptNull desc` | Nullable integer |
| `mkFloatOpt default desc` | Float option |
| `mkListOpt type default desc` | List option |
| `mkAttrsOpt default desc` | Attrs option |
| `mkEnumOpt values default desc` | Enum option |
| `mkPackageOptNull desc` | Nullable package |
| `mkPackageWithFallback cfg pkg` | Get package with fallback |
| `mkConditionalPackages cond pkgs` | Conditional package list |
| `mkAppAssertions name cfg` | Standard assertions |
| `enabled` / `disabled` | Enable/disable shorthand |

### Pre-defined Option Templates

```nix
mkTerminalOptions "AppName"           # fontSize, fontFamily, theme, extraConfig
mkDevelopmentToolOptions "ToolName"   # package, extraConfig, aliases
mkSystemToolOptions "ToolName"        # package, aliases, extraConfig
mkCloudToolOptions "ToolName"         # region, profile, extraConfig
mkSuiteOptions "name" modules         # Home Manager suites
mkDarwinSuiteOptions "name" modules   # Darwin suites (with extraTaps/Brews/Casks)
```

## Directory Structure

```
.
├── flake.nix              # Snowfall Lib configuration
├── lib/
│   ├── default.nix        # Core lib functions + Darwin helpers
│   └── home.nix           # Home Manager option templates
├── modules/
│   ├── darwin/            # System-level modules
│   │   ├── core/          # Nix settings, system defaults
│   │   ├── homebrew/      # Homebrew configuration
│   │   ├── suites/        # common, development, system, media, communication, printing, gaming
│   │   ├── system/        # macOS system settings
│   │   └── user/          # Darwin user account
│   └── home/              # User-level modules
│       ├── programs/
│       │   ├── cloud/     # colima, awscli, gcp, orbstack, podman
│       │   ├── development/  # git, direnv, kubectl, helm, opencode
│       │   ├── shell/     # zsh
│       │   ├── system/    # bat, eza, fzf, starship, zoxide
│       │   └── terminal/  # alacritty, tmux
│       ├── services/      # scrypted
│       ├── suites/        # common, development
│       └── user/          # Home Manager user config
├── systems/aarch64-darwin/  # Host configurations (mini, m4, longshun)
├── homes/aarch64-darwin/    # Home Manager configs (killtw@mini, etc.)
└── shells/                  # Development shells
```

## Naming Conventions

- **Module paths**: lowercase, hyphen-separated (`programs.development.git`)
- **Option names**: camelCase (`userName`, `enableDelta`, `autoStart`)
- **Suite modules list**: hyphen-separated (`["bitwarden-cli" "raycast"]`)
- **Config references**: `cfg = config.${namespace}.path.to.module;`

## Suite System

### Darwin Suites (Homebrew apps)

```nix
${namespace}.suites.development = {
  enable = true;
  modules = ["tableplus" "lens"];       # Include only these
  excludeModules = ["lens"];            # Or exclude specific ones
  extraCasks = ["docker"];              # Additional Homebrew casks
  extraBrews = ["gstreamer"];           # Additional Homebrew formulas
  extraMasApps = { Xcode = 497799835; };  # Mac App Store apps
  extraPackages = [ pkgs.terraform ];   # Nix packages
};
```

### Home Manager Suites

```nix
${namespace}.suites.common = {
  enable = true;
  modules = ["git" "zsh" "bat" ...];    # Available modules
  excludeModules = ["tmux"];            # Exclude specific
};
```

## Important Rules

### DO
- Run `git add .` before testing (Snowfall requires tracked files)
- Test with `nix build --dry-run` before applying
- Use `mkPackageWithFallback cfg pkgs.default` for packages
- Include assertions using `mkAppAssertions`
- Use option templates (`mkSystemToolOptions`, etc.) when appropriate
- Follow the `with lib; with lib.${namespace};` pattern

### DO NOT
- Skip syntax validation (`nix-instantiate --parse`)
- Hard-code configurable values
- Mix Darwin suites with manual Homebrew config in same module
- Forget to add `assertions = mkAppAssertions "Name" cfg;`

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Module not recognized | `git add .` - Snowfall needs tracked files |
| Silent build failure | Add `--show-trace` flag |
| Syntax errors | `nix-instantiate --parse file.nix` |
| Option type mismatch | Check helper function signature |
| Package not found | Use `mkPackageWithFallback cfg pkgs.fallback` |

## Quick Workflow

```bash
# 1. Syntax check
nix-instantiate --parse modules/home/programs/category/tool/default.nix

# 2. Track files
git add .

# 3. Test build
nix build --dry-run .#homeConfigurations."killtw@mini".activationPackage

# 4. Apply
home-manager switch --flake .#killtw@mini

# Or for Darwin:
nix build --dry-run .#darwinConfigurations.mini.system
sudo darwin-rebuild switch --flake .#mini
```

## Example: Adding a New Home Manager Module

```nix
# modules/home/programs/system/newtool/default.nix
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.system.newtool;
in
{
  options.${namespace}.programs.system.newtool = mkSystemToolOptions "NewTool" // {
    extraFeature = mkBoolOpt false "Enable extra feature";
  };

  config = mkIf cfg.enable {
    assertions = mkAppAssertions "NewTool" cfg;

    home.packages = [ (mkPackageWithFallback cfg pkgs.newtool) ];
    
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable cfg.aliases;
  };
}
```

Then add to a suite in `modules/home/suites/common/default.nix`:
```nix
availableModules = [ ... "newtool" ];
# And in config:
system.newtool = mkIf (elem "newtool" (subtractLists cfg.excludeModules cfg.modules)) {
  enable = true;
};
```
