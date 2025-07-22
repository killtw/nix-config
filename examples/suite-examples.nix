# Suite Configuration Examples
# This file demonstrates various ways to use the suite architecture

{ lib, pkgs, config, namespace, ... }:

{
  # Example 1: Complete User Setup (推薦)
  # Perfect for most users - includes everything needed for daily work
  example-complete-user = {
    ${namespace}.suites.common.enable = true;

    # This enables all essential tools:
    # - git, direnv (development basics)
    # - zsh (modern shell)
    # - bat, eza, fzf, zoxide, starship (modern CLI tools)
    # - alacritty, tmux (terminal tools)
  };

  # Example 2: Developer Setup
  # For developers who need professional development tools
  example-developer = {
    ${namespace}.suites = {
      common.enable = true;      # All essential and terminal tools
      development.enable = true; # kubectl, helm, awscli, gcp, colima
    };
  };

  # Example 3: Custom Shell Setup
  # For users who want to configure shell manually
  example-custom-shell = {
    ${namespace}.suites.common = {
      enable = true;
      excludeModules = ["zsh"];  # Don't use zsh from suite
    };

    # Configure shell manually if needed
    programs.bash.enable = true;  # Use system bash configuration
  };

  # Example 4: Minimal Setup
  # For users who only want basic CLI tools without terminal apps
  example-minimal = {
    ${namespace}.suites.common = {
      enable = true;
      excludeModules = ["alacritty" "tmux"];  # No terminal apps
    };
  };

  # Example 5: Custom Development Environment
  # Fine-tuned configuration for specific needs
  example-custom-development = {
    # Enable suites
    ${namespace}.suites = {
      common.enable = true;
      development.enable = true;
    };

    # Then customize individual modules
    ${namespace}.development.git = {
      userName = "Jane Developer";
      userEmail = "jane@company.com";
    };

    ${namespace}.system.starship = {
      preset = "nerd-font";
    };
        enable = true;
        includeKubernetes = true;
        includeContainers = false;  # Don't need containers locally

        gitConfig = {
          userName = "Jane Developer";
          userEmail = "jane@company.com";
          enableDelta = true;
          enableLfs = true;
        };

        kubernetesConfig = {
          defaultNamespace = "development";
          enableCompletion = true;
          enableKubectx = true;
        };

        # Exclude helm if not needed
        excludeModules = ["helm"];
      };

      # Terminal suite with custom theme
      terminal = {
        enable = true;
        fontSize = 13.0;
        theme = "dark";

        alacrittyConfig = {
          opacity = 0.95;
          startupMode = "Maximized";
          padding = {
            x = 20;
            y = 20;
          };
        };

        tmuxConfig = {
          prefix = "'C-a'";  # Use screen-style prefix
          enableMouse = true;
          statusBar = {
            position = "top";
            interval = 2;
          };
        };
      };

      # System suite with custom colors
      system = {
        enable = true;
        theme = "dark";

        batConfig = {
          theme = "Monokai Extended";
          showLineNumbers = true;
          showGrid = true;
        };

        fzfConfig = {
          colorScheme = "catppuccin";
          enablePreview = true;
        };

        starshipConfig = {
          preset = "nerd-font";
          enableGitStatus = true;
          enableKubernetes = true;
          enableAws = false;
        };
      };

      # Shell suite with custom plugins
      shell = {
        enable = true;
        defaultShell = "zsh";

        zshConfig = {
          enableZinit = true;
          plugins = [
            "git"
            "docker"
            "kubectl"
            "aws"
            "terraform"
          ];
        };

        aliasConfig = {
          enableGitAliases = true;
          enableSystemAliases = true;
          enableSafetyAliases = true;
        };
      };
    };
  };

  # Example 4: Frontend Developer Setup
  # Focused on frontend development without heavy cloud tools
  example-frontend-developer = {
    ${namespace}.suites = {
      globalConfig = {
        user = {
          name = "Alex Frontend";
          email = "alex@startup.com";
        };
        preferences.editor = "code";
      };

      development = {
        enable = true;
        includeKubernetes = false;  # Frontend doesn't need k8s
        includeContainers = true;   # But needs Docker for local dev

        # Only include git and direnv
        modules = ["git" "direnv"];
      };

      terminal = {
        enable = true;
        theme = "light";  # Prefer light theme
        fontSize = 14.0;
      };

      system = {
        enable = true;
        theme = "light";

        # Exclude zoxide, prefer regular cd
        excludeModules = ["zoxide"];
      };

      shell = {
        enable = true;
        zshConfig = {
          plugins = [
            "git"
            "node"
            "npm"
            "yarn"
          ];
        };
      };
    };
  };

  # Example 5: DevOps Engineer Setup
  # Heavy focus on cloud and infrastructure tools
  example-devops-engineer = {
    ${namespace}.suites = {
      globalConfig = {
        user = {
          name = "Sam DevOps";
          email = "sam@infrastructure.com";
        };
        preferences = {
          editor = "vim";
          shell = "bash";  # Prefer bash for scripts
        };
      };

      development = {
        enable = true;
        includeKubernetes = true;
        includeContainers = true;

        kubernetesConfig = {
          defaultNamespace = "kube-system";
          enableKubectx = true;
        };
      };

      cloud = {
        enable = true;
        defaultRegion = "us-east-1";

        awsConfig = {
          region = "us-east-1";
          enableCompletion = true;
          enableS3Transfer = true;
        };

        gcpConfig = {
          enableBetaCommands = true;
          enableCompletion = true;
        };

        colimaConfig = {
          cpu = 6;
          memory = 12;
          runtime = "containerd";
        };
      };

      terminal = {
        enable = true;
        tmuxConfig = {
          enableMouse = false;  # Prefer keyboard-only
          statusBar.position = "bottom";
        };
      };

      system = {
        enable = true;
        starshipConfig = {
          enableKubernetes = true;
          enableAws = true;
          enableGcp = true;
        };
      };

      shell = {
        enable = true;
        defaultShell = "bash";

        bashConfig = {
          enableBashCompletion = true;
        };

        aliasConfig = {
          enableSystemAliases = true;
          enableSafetyAliases = false;  # DevOps knows what they're doing
        };
      };
    };
  };

  # Example 6: Minimal Terminal User
  # Just wants a nice terminal experience
  example-terminal-user = {
    ${namespace}.suites.quickEnable.terminalUser = true;

    # Override some defaults
    ${namespace}.suites = {
      globalConfig = {
        fontSize = 16.0;  # Larger font for readability
        theme = "auto";   # Auto-detect theme
      };

      terminal = {
        alacrittyConfig = {
          opacity = 1.0;  # No transparency
          startupMode = "Windowed";
        };
      };

      system = {
        fzfConfig = {
          colorScheme = "gruvbox";
        };
      };
    };
  };

  # Example 7: System Administrator
  # Focus on system management and cloud tools
  example-system-admin = {
    ${namespace}.suites.quickEnable.systemAdmin = true;

    # Additional customizations
    ${namespace}.suites = {
      cloud = {
        awsConfig = {
          region = "us-west-2";
          profile = "admin";
        };

        colimaConfig = {
          cpu = 8;
          memory = 16;
        };
      };

      system = {
        starshipConfig = {
          enableAws = true;
          enableGcp = true;
          enableKubernetes = true;
        };
      };
    };
  };

  # Example 8: Mixed Environment (Work + Personal)
  # Shows how to create different profiles
  example-work-profile = {
    ${namespace}.suites = {
      globalConfig = {
        user = {
          name = "Professional Name";
          email = "work@company.com";
        };
        theme = "dark";
      };

      development = {
        enable = true;
        gitConfig = {
          userName = "Professional Name";
          userEmail = "work@company.com";
        };
      };

      cloud = {
        enable = true;
        awsConfig = {
          profile = "work";
          region = "us-east-1";
        };
      };
    };
  };

  example-personal-profile = {
    ${namespace}.suites = {
      globalConfig = {
        user = {
          name = "Personal Name";
          email = "personal@gmail.com";
        };
        theme = "light";
      };

      development = {
        enable = true;
        includeContainers = true;
        gitConfig = {
          userName = "Personal Name";
          userEmail = "personal@gmail.com";
        };
      };

      terminal = {
        enable = true;
        theme = "light";
      };
    };
  };
}
