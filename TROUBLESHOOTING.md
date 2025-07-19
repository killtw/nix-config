# Troubleshooting Guide

This guide helps you diagnose and fix common issues with this Snowfall-based Nix configuration.

## Table of Contents

- [Build Failures](#build-failures)
- [Module Issues](#module-issues)
- [Homebrew Problems](#homebrew-problems)
- [Performance Issues](#performance-issues)
- [System Recovery](#system-recovery)
- [Getting Help](#getting-help)

## Build Failures

### Circular Dependency Errors

**Symptoms:**
```
error: infinite recursion encountered
```

**Causes:**
- Using `namespace` parameter in Home Manager modules
- Circular references between modules

**Solutions:**

1. **Check Home Manager modules for `namespace` usage:**
   ```bash
   grep -r "namespace" modules/home/
   ```

2. **Fix Home Manager modules:**
   ```nix
   # ❌ Don't do this in Home Manager modules
   { config, lib, namespace, ... }:
   let
     cfg = config.${namespace}.module;
   
   # ✅ Do this instead
   { config, lib, ... }:
   let
     cfg = config.programs.module-config;
   ```

3. **Verify module structure:**
   ```bash
   # Check if modules are recognized
   nix eval .#homeModules --apply builtins.attrNames
   ```

### Module Not Found Errors

**Symptoms:**
```
error: The option 'programs.shell-config' does not exist
```

**Causes:**
- Module not properly recognized by Snowfall
- Git changes not staged
- Module syntax errors

**Solutions:**

1. **Stage git changes:**
   ```bash
   git add .
   ```

2. **Check module syntax:**
   ```bash
   nix-instantiate --parse modules/home/shell/default.nix
   ```

3. **Verify module recognition:**
   ```bash
   nix eval .#homeModules --apply builtins.attrNames
   nix eval .#darwinModules --apply builtins.attrNames
   ```

4. **Check flake structure:**
   ```bash
   nix flake show
   ```

### Evaluation Errors

**Symptoms:**
```
error: attribute 'xyz' missing
```

**Solutions:**

1. **Use show-trace for detailed errors:**
   ```bash
   nix build .#darwinConfigurations.mini.system --show-trace
   ```

2. **Check option paths:**
   ```bash
   # Verify option exists
   nix eval .#darwinConfigurations.mini.options.killtw.user.name.type
   ```

3. **Validate configuration:**
   ```bash
   nix flake check
   ```

## Module Issues

### Home Manager Module Problems

**Common Issues:**

1. **Using deprecated options:**
   ```nix
   # ❌ Deprecated
   programs.zsh.initExtra = "...";
   
   # ✅ Current
   programs.zsh.initContent = "...";
   ```

2. **Incorrect option types:**
   ```nix
   # ❌ Wrong type
   setting = mkOption {
     type = types.string;  # Should be types.str
   };
   
   # ✅ Correct type
   setting = mkOption {
     type = types.str;
   };
   ```

3. **Missing assertions:**
   ```nix
   config = mkIf cfg.enable {
     assertions = [
       {
         assertion = cfg.userName != "";
         message = "User name cannot be empty";
       }
     ];
   };
   ```

### Darwin Module Problems

**Common Issues:**

1. **Incorrect system defaults:**
   ```bash
   # Check available defaults
   man configuration.nix
   
   # Or check online documentation
   # https://daiderd.com/nix-darwin/manual/
   ```

2. **Service configuration errors:**
   ```nix
   # Check service syntax
   launchd.user.agents.myservice = {
     serviceConfig = {
       ProgramArguments = [ "${pkgs.program}/bin/program" ];
       RunAtLoad = true;
     };
   };
   ```

## Homebrew Problems

### Installation Issues

**Symptoms:**
- Homebrew applications not installing
- Permission errors
- Rosetta issues on Apple Silicon

**Solutions:**

1. **Check nix-homebrew configuration:**
   ```bash
   nix eval .#darwinConfigurations.mini.config.nix-homebrew.enable
   ```

2. **Verify Homebrew is working:**
   ```bash
   brew doctor
   ```

3. **Reset Homebrew if needed:**
   ```bash
   # Uninstall Homebrew
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
   
   # Rebuild system (will reinstall Homebrew)
   darwin-rebuild switch --flake .#mini
   ```

4. **Check Rosetta installation:**
   ```bash
   # Install Rosetta if needed
   sudo softwareupdate --install-rosetta --agree-to-license
   ```

### Application Not Found

**Symptoms:**
- Applications listed in configuration but not installed

**Solutions:**

1. **Check application names:**
   ```bash
   # Search for correct cask name
   brew search --cask "app-name"
   ```

2. **Verify Brewfile generation:**
   ```bash
   nix eval .#darwinConfigurations.mini.config.homebrew.brewfile --raw
   ```

3. **Check for typos in configuration:**
   ```nix
   casks = [
     "visual-studio-code"  # Correct
     # "vscode"            # Incorrect
   ];
   ```

## Performance Issues

### Slow Builds

**Symptoms:**
- Long build times
- High CPU/memory usage during builds

**Solutions:**

1. **Enable binary caches:**
   ```bash
   # Add to ~/.config/nix/nix.conf
   substituters = https://cache.nixos.org/ https://nix-community.cachix.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

2. **Optimize build settings:**
   ```bash
   # Add to ~/.config/nix/nix.conf
   max-jobs = auto
   cores = 0
   ```

3. **Use cachix for community caches:**
   ```bash
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   cachix use nix-community
   ```

### Large Nix Store

**Symptoms:**
- Disk space issues
- Large `/nix/store` directory

**Solutions:**

1. **Regular cleanup:**
   ```bash
   # Clean user profiles
   nix-collect-garbage -d
   
   # Clean system profiles (requires sudo)
   sudo nix-collect-garbage -d
   
   # Clean specific profile
   nix-collect-garbage --delete-older-than 30d
   ```

2. **Optimize store:**
   ```bash
   nix-store --optimize
   ```

3. **Check store size:**
   ```bash
   du -sh /nix/store
   nix path-info --closure-size /run/current-system
   ```

## System Recovery

### Rollback to Previous Generation

**When to use:**
- New configuration breaks system
- Applications not working after update

**Steps:**

1. **List generations:**
   ```bash
   darwin-rebuild --list-generations
   ```

2. **Rollback to previous:**
   ```bash
   darwin-rebuild --rollback
   ```

3. **Switch to specific generation:**
   ```bash
   darwin-rebuild --switch-generation 42
   ```

### Emergency Recovery

**If system is severely broken:**

1. **Boot into recovery mode:**
   - Hold Command+R during startup

2. **Use Terminal in recovery:**
   ```bash
   # Mount main disk
   diskutil list
   diskutil mount /dev/disk1s1  # Adjust as needed
   
   # Access Nix
   /Volumes/Macintosh\ HD/nix/var/nix/profiles/system/bin/darwin-rebuild --rollback
   ```

3. **Restore from backup:**
   ```bash
   # If you have Time Machine backup
   # Restore from backup and rebuild
   cd ~/.config/nix
   git pull origin main
   darwin-rebuild switch --flake .#mini
   ```

### Configuration Backup

**Preventive measures:**

1. **Regular git commits:**
   ```bash
   cd ~/.config/nix
   git add .
   git commit -m "Working configuration $(date)"
   git push origin main
   ```

2. **Tag stable versions:**
   ```bash
   git tag -a v1.0 -m "Stable configuration"
   git push origin v1.0
   ```

3. **Export current generation:**
   ```bash
   # Save current system closure
   nix-store --export $(nix-store -qR /run/current-system) > system-backup.nar
   ```

## Getting Help

### Diagnostic Information

**Collect this information when asking for help:**

1. **System information:**
   ```bash
   system_profiler SPSoftwareDataType
   uname -a
   ```

2. **Nix version:**
   ```bash
   nix --version
   ```

3. **Configuration status:**
   ```bash
   darwin-rebuild --list-generations
   nix flake show
   ```

4. **Error logs:**
   ```bash
   # Full error trace
   darwin-rebuild switch --flake .#mini --show-trace 2>&1 | tee error.log
   ```

### Community Resources

1. **NixOS Discourse:**
   - https://discourse.nixos.org/
   - Best for detailed questions and discussions

2. **Nix Community Discord:**
   - https://discord.gg/RbvHtGa
   - Good for quick questions and real-time help

3. **GitHub Issues:**
   - [nix-darwin issues](https://github.com/LnL7/nix-darwin/issues)
   - [Home Manager issues](https://github.com/nix-community/home-manager/issues)
   - [Snowfall Lib issues](https://github.com/snowfallorg/lib/issues)

4. **Documentation:**
   - [Nix Manual](https://nixos.org/manual/nix/stable/)
   - [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
   - [Home Manager Manual](https://nix-community.github.io/home-manager/)

### Reporting Issues

**When reporting issues, include:**

1. **Clear description** of the problem
2. **Steps to reproduce** the issue
3. **Expected vs actual behavior**
4. **Error messages** (full trace)
5. **System information** (macOS version, hardware)
6. **Configuration files** (relevant parts)

**Example issue report:**
```
## Problem
Darwin rebuild fails with circular dependency error

## Steps to Reproduce
1. Clone configuration
2. Run `darwin-rebuild switch --flake .#mini`

## Error Message
```
error: infinite recursion encountered
```

## System Info
- macOS: 14.0 (Apple Silicon)
- Nix: 2.18.1
- nix-darwin: latest

## Configuration
[Attach relevant configuration files]
```

This troubleshooting guide should help you resolve most common issues. Remember to always backup your working configuration before making significant changes!
