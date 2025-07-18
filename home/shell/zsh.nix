{ ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;

    completionInit = "";

    initContent = ''
      export XDG_CACHE_HOME=~/.cache
      export PATH=$PATH:./vendor/bin:~/bin

      setopt auto_cd multios prompt_subst promptsubst auto_pushd pushd_ignore_dups pushdminus
      autoload -Uz colors && colors
      autoload -Uz select-word-style && select-word-style shell
      autoload -Uz url-quote-magic
      zle -N self-insert url-quote-magic

      zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

      source "${../dotfiles/zinit}"
      source "${../dotfiles/aliases}"
    '';

    autosuggestion = {
      enable = true;
      strategy = ["history" "completion"];
    };
  };
}
