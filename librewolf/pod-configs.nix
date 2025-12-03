let
  name = "librewolf-test-pod";
  nixosConfigurationSource = ./configuration.nix;
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
  uname = "dev";
  userHome = "/home/dev";
  etcActivation = true;
  homeActivation = true;
in
{
  inherit
    name
    nixosConfigurationSource
    homeManagerConfigurationSource
    channelsList
    uname
    userHome
    etcActivation
    homeActivation
    ;
}
