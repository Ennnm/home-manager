{ config, pkgs, userinfo, atomi, ... }:

####################
# Upstream Mutator #
####################

let mutator = import ./upstream.nix; in

##############################
  # Import additional modules  #
  ##############################

let lib = import ./lib.nix { inherit pkgs; }; in
with (with lib;{ inherit zshCustomPlugins liveAutoComplete; });
with pkgs;

let output = {
  #########################
  # Install packages here #
  #########################
  home.packages = [

    # System requirements
    uutils-coreutils

    # ESD Tooling
    kubernetes-helm
    kubelogin-oidc
    cachix
    kubectl
    docker
    # awscli2

    # apps
    vscode
  ];
  ##################################################
  # Addtional environment variables for your shell #
  ##################################################
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  #################################
  # Addtional PATH for your shell #
  #################################
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.krew/bin"
    "$HOME/bin"
    "/usr/local/bin"
    "/Users/chiewjiaen/tools/flutter/bin"
  ];

  ##########################
  # Program Configurations #
  ##########################
  programs = {

    # Git Configurations
    git = {
      enable = true;
      userEmail = "${userinfo.email}";
      userName = "${userinfo.gituser}";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = "true";
      };
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
        cleanbr = "branch --merged \| egrep -v '(^\\*\|master\|develop)' \| xargs git branch -d"; #  g br --merged | egrep -v '(develop)' | xargs git branch -d
      };
    };

    # Shell Configurations
    zsh = {

      enable = true;
      enableCompletion = false;

      # Add ~/.zshrc here
      initExtra = ''
        eval "$(rbenv init - zsh)"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
      '';

      # Oh-my-zsh configurations
      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          ZSH_CUSTOM="${zshCustomPlugins}"
          ZSH_THEME="cloud"
          zstyle ':completion:*:*:man:*:*' menu select=long search
          zstyle ':autocomplete:*' recent-dirs zoxide
        '';
        plugins = [
          "git"
          "docker"
          "kubectl"
          "pls"
          "aws"
        ];
      };

      # Aliases
      shellAliases = {
        cat = "bat -p";
        hms = "home-manager switch --impure --flake $HOME/home-manager-config#$USER";
        hmsz = "home-manager switch --impure --flake $HOME/home-manager-config#$USER && source ~/.zshrc";
        configterm = "POWERLEVEL9K_CONFIG_FILE=\"$HOME/home-manager-config/p10k-config/.p10k.zsh\" p10k configure";
        art="php artisan";
        artt = "php artisan tinker";
        arttest = "php artisan tinker --env=testing";
        arttt = "while true; do php artisan tinker; done";
        artttest = "while true; do php artisan tinker --env=testing; done";
        artm = "php artisan migrate";
        artmt = "php artisan migrate --env=testing";
        reloadcli="source $HOME/.zshrc";
        con-gotrade-staging="aws ssm start-session --target i-096e34cb28bfd435d --region=ap-southeast-1";
        con-gotrade-staging-b="aws ssm start-session --target i-070f7870e96cf239f";
        con-indogotrade-stg="aws ssm start-session --target i-025aaf1c45ed93bc5 --region=ap-southeast-1";
        con-tradecharlie-prod="aws ssm start-session --target i-08795e35ca86cdadd --region ap-southeast-1";
        con-gotradeindo-prod="aws ssm start-session --target i-078657840f061ce16 --region ap-southeast-3";
        rtunnel-db-tr8logging="ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13309:logging-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@54.255.27.224";
        rtunnel-mongo-tradecharlie="ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 27018:request-logger-staging-sg-mongodb.cluster-c9ilcrldgvqh.ap-southeast-1.docdb.amazonaws.com:27017 ubuntu@54.255.27.224";
        switch-bastion-a="export GOTRADE_BASTION_IP=\"54.255.27.224\"";
        switch-bastion-b="export GOTRADE_BASTION_IP=\"54.255.37.152\"";
        rtunnel-db-tradecharlie= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13306:tradecharlie-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-tradecrm= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13307:tradecrm-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-tr8stock= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13308:tr8stock-staging-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-db-gti-staging= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13320:gti-staging-db-v2.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@ec2-54-151-194-149.ap-southeast-1.compute.amazonaws.com";
        rtunnel-db-redshift-postgres= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13309:redshift-postgres.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:5432 ubuntu@$GOTRADE_BASTION_IP";
        rtunnel-es-tr8logging= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem ubuntu@$GOTRADE_BASTION_IP -N -L 9200:vpc-tr8logging-staging-pi7awf7acihfbn2sm3alpm35yi.ap-southeast-1.es.amazonaws.com:443";
        rtunnel-es-tr8logging-prod= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem ubuntu@54.179.29.60 -N -L 9200:vpc-tr8logging-production-4rowsmg5npy7ec4wvtdpt46dti.ap-southeast-1.es.amazonaws.com:443";
        rtunnel-db-tr8data= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13301:tr8data-production-db.c9ilcrldgvqh.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@54.179.29.60";
        rtunnel-redshift-tr8data= "ssh -i ~/.ssh/aws-sg-tr8-sha2.pem -N -L 13302:gotrade-production-redshift-cluster.cltn77nltqlf.ap-southeast-1.redshift.amazonaws.com:5439 ubuntu@54.179.29.60";
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

      # ZSH ZPlug Plugins
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
          # {
          #   name = "romkatv/powerlevel10k";
          #   tags = [ as:theme depth:1 ];
          # }
        ];
      };
    };

    # Enable GPG
    gpg = {
      enable = true;
    };

    # Enable SSH
    ssh = {
      enable = true;
       extraConfig = ''
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519
      '';
    };

    # Enable bat
    bat = {
      enable = true;
    };

    # enable exa
    exa = {
      enable = true;
      enableAliases = true;
    };

    # enable fzf
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # enable zoxide
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}; in
mutator { outputs = output; system = userinfo.system; nixpkgs = pkgs; }
