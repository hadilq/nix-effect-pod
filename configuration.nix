{ homeManagerConfigurationSource
, homeManagerSource
, username
, userHome
}:
{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
    (import "${homeManagerSource}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = { config, pkgs, lib, ... } :{
      imports = [
        (import homeManagerConfigurationSource)
      ];

      programs.home-manager.enable = true;
      home.username = username;
      home.homeDirectory = userHome;

      home.stateVersion = "23.11";
    };
  };

  boot.isContainer = true;
  boot.loader.grub.enable = false;
  services.journald.console = "/dev/console";

  environment.noXlibs = false;
  services.xserver = {
    enable = true;
    layout = "us";
    displayManager.lightdm.enable = false;
    displayManager.startx.enable = false;
  };

  users = {
    mutableUsers = true;
    users = {
      ${username} = {
        isNormalUser = true;
        home = userHome;
        description = "Development";
        extraGroups = [ ];
        shell = pkgs.bashInteractive;
      };
    };
  };

  time.timeZone = "Canada/Eastern";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  system.stateVersion = "24.05";
}
