{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #enableAutosuggestions = false;
    enableVteIntegration = true;
    # enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      # theme = "agnoster";
      plugins = [
        "git"
        "extract"
        "colored-man-pages"
        "sudo"
        # "command-not-found"
        "python"
        "vi-mode"
        # "autojump"
        "colorize"
        "tmux"
        "gitignore"
        "safe-paste"
      ];
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.2.0";
          sha256 = "1gfyrgn23zpwv1vj37gf28hf5z0ka0w5qm6286a7qixwv7ijnrx9";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
    ];
    shellAliases = {
      v = "${pkgs.neovim}/bin/nvim";
      r = "${pkgs.ranger}/bin/ranger";
      grep = "${pkgs.busybox}/bin/grep --color=auto";
      screenfetch =
        "${pkgs.screenfetch}/bin/screenfetch|${pkgs.lolcat}/bin/lolcat";
      xclip = "${pkgs.xclip}/bin/xclip -selection c";
      ls = "${pkgs.lsd}/bin/lsd --group-dirs first";
      top = "${pkgs.htop}/bin/htop";
      htop = "${pkgs.htop}/bin/htop";
      rm = "${pkgs.rmtrash}/bin/rmtrash";
      rm-without-trash = "${pkgs.busybox}/bin/rm";
      s = "sudo su";
      gita = "${pkgs.git}/bin/git add .";
      gitc = "${pkgs.git}/bin/git commit";
      tmuxt = "${pkgs.tmux}/bin/tmux split -p 10";
    };
    initExtraFirst = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    initExtra = builtins.readFile ./zshrc.zsh + ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      export FZF_DEFAULT_COMMAND='${pkgs.ag}/bin/ag -p ~/.gitignore -g ""'
    '';
  };
  home.file.".p10k.zsh".source = ./p10k.zsh;
  programs.autojump.enable = true;
}
