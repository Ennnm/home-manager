{ config, pkgs, userinfo, atomi, ... }:

let complex = import ./complex.nix { inherit pkgs; }; in

with (
  with complex;
  { inherit setup-devbox-server customDir linuxService liveAutoComplete; }
);

with pkgs;

# GUI applications
let apps = [
  vscode
]; in

# CLI tools
let tools = [

  # Core Utils
  uutils-coreutils

  # DevOps tooling
  cachix
  kubectl
  docker
  awscli2
  atomi.awsmfa

  # Setup
  setup-devbox-server

]; in
{
  home.packages = (if userinfo.remote then tools else tools ++ apps);
  home.file = {
    direnv = {
      target = ".config/direnv/lib/invalidate.sh";
      executable = true;
      text = ''
        #!/usr/bin/env bash

        use_atomi_nix() {
            direnv_load nix-shell --show-trace "$@" --run "$(join_args "$direnv" dump)"
            if [[ $# == 0 ]]; then
              watch_file default.nix shell.nix nix/env.nix nix/packages.nix nix/shells.nix
            fi
        }
      '';
    };
  };

  services = (if userinfo.linux then linuxService else { });
  programs = complex.programs // {
    # Git Configurations
    git = {

      enable = true;
      userEmail = "${userinfo.email}";
      userName = "${userinfo.gituser}";

      extraConfig = {
        init.defaultBranch = "main";
      };

      includes = [
        { path = "$HOME/.gitconfig"; }
      ];

      lfs = {
        enable = true;
      };

      aliases ={
        a = "add";
        c = "commit";
        ca = "commit --amend";
        can = "commit --amend --no-edit";
        cl = "clone";
        cm = "commit -m";
        co = "checkout";
        cp = "cherry-pick";
        cpx = "cherry-pick -x";
        d = "diff";
        f = "fetch";
        fo = "fetch origin";
        fu = "fetch upstream";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        pl = "pull";
        pr = "pull -r";
        ps = "push";
        psf = "push -f";
        rb = "rebase";
        rbi = "rebase -i";
        r = "remote";
        ra = "remote add";
        rr = "remote rm";
        rv = "remote -v";
        rs = "remote show";
        st = "status";
        br = "branch";
        cleanbr = "branch --merged \| egrep -v '(^\\*\|master\|develop)' \| xargs git branch -d";
      };
      #       pull = {
      #   rebase=true;
      # };
    };

    zsh = {
      enable = true;
      enableCompletion = false;
      # ZSH configurations
      initExtra = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        PATH="$PATH:/$HOME/.local/bin"

        source ~/.zshrc.bak

        export NIXPKGS_ALLOW_UNFREE=1
        unalias gm
        export AWS_PROFILE=default-mfa
      '';

      # Oh-my-zsh configurations

      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          ZSH_CUSTOM="${customDir}"
          ZSH_THEME="cloud"
        '';
        plugins = [
          "git"
          "docker"
          "kubectl"
          "pls"
          "aws"
          "nvm"
        ];
      };

      # Aliases
      shellAliases = {
        cat = "bat -p";
        hms = "home-manager switch --impure --flake $HOME/home-manager-config#$USER";
        hmsz = "home-manager switch --impure --flake $HOME/home-manager-config#$USER && source ~/.zshrc";
        mfa = "awsmfa auth -u tr8jiaen -t";
        artt = "php artisan tinker";
        arttest = "php artisan tinker --env=testing";
        arttt = "while true; do php artisan tinker; done";
        artttest = "while true; do php artisan tinker --env=testing; done";
        artm = "php artisan migrate";
        artmt = "php artisan migrate --env=testing";
      };

      plugins = [
        # p10k config
        {
          name = "powerlevel10k-config";
          src = ./p10k-config;
          file = ".p10k.zsh";
        }
        # live autocomplete
        liveAutoComplete
      ];

      zplug = {
        enable = true;
        plugins = [
          # Exa auto completes
          {
            name = "ogham/exa";
            tags = [ use:completions/zsh ];
          }
          # alt j to do JQ querry
          {
            name = "reegnz/jq-zsh-plugin";
          }
          # make sound when commands longer than 15 seconds completed
          {
            name = "kevinywlui/zlong_alert.zsh";
          }
          # remind you you have aliases
          {
            name = "djui/alias-tips";
          }
          # themes
          {
            name = "romkatv/powerlevel10k";
            tags = [ as:theme depth:1 ];
          }
        ];
      };
    };
  };
}
