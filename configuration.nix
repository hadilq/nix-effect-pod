{ homeManagerConfigurationSource
, homeManagerSource
, uname
, userHome
}:
{ pkgs, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
    (import "${homeManagerSource}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${uname} = { ... } :{
      imports = [
        (import homeManagerConfigurationSource)
      ];

      programs.home-manager.enable = true;
      programs.bash.enable = true;
      home.username = uname;
      home.homeDirectory = userHome;

      home.stateVersion = "24.11";
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
      ${uname} = {
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

  system.stateVersion = "24.05";
}
