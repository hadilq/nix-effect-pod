let
  system =  "x86_64-linux";
  # release-24.05
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/805a384895c696f802a9bf5bf4720f37385df547.tar.gz";
  # release-24.05
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/a631666f5ec18271e86a5cde998cba68c33d9ac6.tar.gz";
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

