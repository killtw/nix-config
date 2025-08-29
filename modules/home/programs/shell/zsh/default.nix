# Zsh shell module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.shell.zsh;
in
{
  options.${namespace}.programs.shell.zsh = {
    enable = mkEnableOption "Zsh shell";

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "The Zsh package to use. If null, uses system default.";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for Zsh";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra configuration options for Zsh";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Zsh" cfg;

    programs.zsh = {
      enable = true;
      package = mkPackageWithFallback cfg pkgs.zsh;

      autocd = true;
      autosuggestion = {
        enable = true;
        strategy = ["history" "completion"];
      };

      history = {
        size = 100000;
        save = 100000;
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        extended = true;
      };

      initContent = ''
        export XDG_CACHE_HOME=~/.cache
        export PATH=$PATH:./vendor/bin:~/bin

        setopt auto_cd multios prompt_subst promptsubst auto_pushd pushd_ignore_dups pushdminus
        autoload -Uz colors && colors
        autoload -Uz select-word-style && select-word-style shell
        autoload -Uz url-quote-magic
        zle -N self-insert url-quote-magic

        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

        ### Load Zinit
        ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"
        if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
            command mkdir -p "$(dirname $ZINIT_HOME)"
            command git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
        fi

        source "''${ZINIT_HOME}/zinit.zsh"
        autoload -Uz _zinit
        (( ''${+_comps} )) && _comps[zinit]=_zinit
        ### Zinit loaded

        zi lucid for \
            zdharma-continuum/zinit-annex-bin-gem-node \
            OMZL::completion.zsh \
            OMZL::history.zsh \
            OMZL::key-bindings.zsh

        zi wait lucid for \
            Aloxaf/fzf-tab

        zi wait"3" lucid for \
            has"colima" \
                as"null" id-as"nerdctl" atclone"colima nerdctl install" atpull"%atclone" zdharma-continuum/null \
            has"kubectl" \
                OMZP::kubectl \
                as"program" from"gh" pick"(kubectx|kubens)" ahmetb/kubectx

        zi wait lucid for \
            atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
                zdharma-continuum/fast-syntax-highlighting \
                zdharma-continuum/history-search-multi-word \
            blockf atpull"zinit creinstall -q ." \
                zsh-users/zsh-completions

        function ls() {
            if [ -x "$(command -v eza)" ] ; then
                eza -bh --color=auto "$@"
            else
                /bin/ls "$@"
            fi
        }

        function cat() {
            if [ -x "$(command -v bat)" ] ; then
                bat "$@"
            else
                /bin/cat "$@"
            fi
        }

        function mk() {
            if [ $# -eq 1 ]; then
                mkdir -p "$1" && cd "$1"
            else
                echo "Usage: mk <directory>"
                return 1
            fi
        }

        function extract () {
            if [ -f $1 ] ; then
                case $1 in
                    *.tar.bz2) tar xjf $1 ;;
                    *.tar.gz) tar xzf $1 ;;
                    *.bz2) bunzip2 $1 ;;
                    *.rar) unrar e $1 ;;
                    *.gz) gunzip $1 ;;
                    *.tar) tar xf $1 ;;
                    *.tbz2) tar xjf $1 ;;
                    *.tgz) tar xzf $1 ;;
                    *.zip) unzip "$1" ;;
                    *.Z) uncompress $1 ;;
                    *.7z) 7z x $1 ;;
                    *) echo "'$1' cannot be extracted via extract()" ;;
                esac
            else
                echo "'$1' is not a valid file"
            fi
        }

        function docker-cleanup {
          EXITED=$(docker ps -q -f status=exited)
          DANGLING=$(docker images -q -f "dangling=true")

          if [ "$1" = "--dry-run" ]; then
            echo "==> Would stop containers:"
            echo "$EXITED"
            echo "==> And images:"
            echo "$DANGLING"
          else
            if [ -n "$EXITED" ]; then
              docker rm -f $EXITED
            else
              echo "No containers to remove."
            fi
            if [ -n "$DANGLING" ]; then
              docker rmi -f $DANGLING
            else
              echo "No images to remove."
            fi
          fi
        }


        # PHP
        alias -- x="composer"
        alias -- art="php artisan"

        function tinker() {
            if [ -e "artisan" ] ; then
                if [ -z "$1" ] ; then
                    while true; do php artisan tinker; done
                else
                    php artisan tinker --execute="dd($1);"
                fi
            fi
            [ -e "Rakefile" ] && bundle exec rails c
        }

        function migrate() {
          [ -e "artisan" ] && php artisan migrate "$@"
          [ -e "Rakefile" ] && bundle exec rake db:migrate "$@"
        }

        function rollback() {
          [ -e "artisan" ] && php artisan migrate:rollback "$@"
          [ -e "Rakefile" ] && bundle exec rake db:rollback "$@"
        }

        function phpunit {
            if [ -e "vendor/bin/phpunit" ]; then
                vendor/bin/phpunit "$@"
            elif [[ -x "$(command -v phpunit)" ]]; then
                command phpunit "$@"
            fi
        }
      '';
    } // cfg.extraConfig;
  };
}
