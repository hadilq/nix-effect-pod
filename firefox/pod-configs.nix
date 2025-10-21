let
  system = "x86_64-linux";
  # nixos-24.11
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/057f63b6dc1a2c67301286152eb5af20747a9cb4.tar.gz";
  # release-24.11
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/1bd5616e33c0c54d7a5b37db94160635a9b27aeb.tar.gz";
  name = "firefox-test-machine";
  nixosConfigurationSource = ./configuration.nix;
  podProfileDirPath = ./.;
  homeManagerConfigurationSource = ./home.nix;
  channelsList = [
    {
      name = "nixpkgs";
      url = "https://nixos.org/channels/nixos-24.11-small";
    }
    {
      name = "home-manager";
      url = "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
    }
  ];
  username = "dev";
  userHome = "/home/dev";
  etcActivation = true;
  homeActivation = true;
in
{
  inherit
    system
    pkgsSource
    homeManagerSource
    name
    nixosConfigurationSource
    podProfileDirPath
    homeManagerConfigurationSource
    channelsList
    username
    userHome
    etcActivation
    homeActivation
    ;
}
