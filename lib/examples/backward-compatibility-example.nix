# Example: Backward compatibility module
# This demonstrates how to maintain compatibility with old programs.*-config format
# Location: modules/home/compatibility/default.nix

{ lib, config, namespace, ... }:

with lib;
with lib.${namespace};

{
  # Maintain backward compatibility for old configuration paths
  
  # Git configuration compatibility
  options.programs.git-config = {
    enable = mkEnableOption "Git configuration (legacy)";
  };
  
  config.${namespace}.development.git = mkIf config.programs.git-config.enable {
    enable = true;
    # Use default values from the new module
  };
  
  # Shell configuration compatibility
  options.programs.shell-config = {
    enable = mkEnableOption "Shell configuration (legacy)";
  };
  
  config = mkIf config.programs.shell-config.enable {
    # Enable equivalent suite and individual modules
    ${namespace}.suites.development.enable = true;
    ${namespace}.system = {
      bat.enable = true;
      eza.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      starship.enable = true;
    };
    ${namespace}.shell.zsh.enable = true;
    ${namespace}.cloud = {
      awscli.enable = true;
      gcp.enable = true;
      colima.enable = true;
    };
  };
  
  # Terminal configuration compatibility
  options.programs.terminal-config = {
    enable = mkEnableOption "Terminal configuration (legacy)";
  };
  
  config.${namespace}.terminal = mkIf config.programs.terminal-config.enable {
    tmux.enable = true;
    # Note: alacritty needs to be enabled separately as alacritty-config
  };
  
  # Alacritty configuration compatibility
  options.programs.alacritty-config = {
    enable = mkEnableOption "Alacritty configuration (legacy)";
  };
  
  config.${namespace}.terminal.alacritty = mkIf config.programs.alacritty-config.enable {
    enable = true;
    # Use default values from the new module
  };
  
  # User configuration compatibility
  options.programs.user-config = {
    enable = mkEnableOption "User configuration (legacy)";
    email = mkOption {
      type = types.str;
      default = "killtw@gmail.com";
      description = "The email of the user.";
    };
    fullName = mkOption {
      type = types.str;
      default = "Karl Li";
      description = "The full name of the user.";
    };
    name = mkOption {
      type = types.nullOr types.str;
      default = "killtw";
      description = "The user account.";
    };
  };
  
  config = mkIf config.programs.user-config.enable {
    # This maintains the original user-config functionality
    home = {
      username = mkDefault config.programs.user-config.name;
      homeDirectory = mkDefault (
        if pkgs.stdenv.hostPlatform.isDarwin 
        then "/Users/${config.programs.user-config.name}" 
        else "/home/${config.programs.user-config.name}"
      );
    };
    
    programs.home-manager.enable = true;
    
    # Also configure git with user information
    ${namespace}.development.git = {
      userName = config.programs.user-config.fullName;
      userEmail = config.programs.user-config.email;
    };
  };
  
  # Add warnings for deprecated usage
  warnings = 
    optional config.programs.git-config.enable 
      "programs.git-config is deprecated. Use ${namespace}.development.git instead." ++
    optional config.programs.shell-config.enable 
      "programs.shell-config is deprecated. Use ${namespace}.suites.development or individual modules instead." ++
    optional config.programs.terminal-config.enable 
      "programs.terminal-config is deprecated. Use ${namespace}.terminal.tmux instead." ++
    optional config.programs.alacritty-config.enable 
      "programs.alacritty-config is deprecated. Use ${namespace}.terminal.alacritty instead." ++
    optional config.programs.user-config.enable 
      "programs.user-config is deprecated. Configure home.username and home.homeDirectory directly.";
}
