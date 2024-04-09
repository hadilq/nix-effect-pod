let
  system =  "x86_64-linux";
  # release-23.11
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/d7329da4b1cd24f4383455071346f4f81b7becba.tar.gz";
  # release-23.11
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/d6bb9f934f2870e5cbc5b94c79e9db22246141ff.tar.gz";
  name = "firefox-test-machine";
  nixosConfigurationSource = ./configuration.nix;
  podProfileDirPath = ./.;
  homeManagerConfigurationSource = ./home.nix;
  channelsList = [
    { name = "nixpkgs"; url= "https://nixos.org/channels/nixos-23.11-small"; }
    { name = "home-manager"; url= "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz"; }
  ];
  username = "dev";
  userHome = "/home/dev";
  etcActivation = true;
  homeActivation = true;
in
{
  inherit system pkgsSource homeManagerSource name nixosConfigurationSource podProfileDirPath
    homeManagerConfigurationSource channelsList username userHome etcActivation homeActivation;
}

