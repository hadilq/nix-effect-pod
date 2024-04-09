{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{

  imports = [
    ./../common/vim.nix
    ./../common/shell-tools.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  home.packages = with pkgs; [
    curl
    ripgrep
    xclip
    zsh
    glab
    gh
    rust-analyzer # rust language server
    rustfmt
  ];

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = "HISTSIZE=10000";

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" "kubectl" ];
    };
  };

  programs.git = {
    enable = true;

    includes = [{
      contents = {
        init.defaultBranch = "main";
      };
    }];
  };
}

