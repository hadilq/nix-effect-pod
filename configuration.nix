{
  pkgs,
  modulesPath,
  podConfigs,
  ...
}:
{
  imports = [
    (import podConfigs.nixosConfigurationSource)
    "${toString modulesPath}/virtualisation/docker-image.nix"
    (import "${podConfigs.homeManagerSource}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${podConfigs.uname} =
      { ... }:
      {
        imports = [
          (import podConfigs.homeManagerConfigurationSource)
        ];

        programs.home-manager.enable = true;
        programs.bash.enable = true;
        home.username = podConfigs.uname;
        home.homeDirectory = podConfigs.userHome;

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
      ${podConfigs.uname} = {
        isNormalUser = true;
        home = podConfigs.userHome;
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
