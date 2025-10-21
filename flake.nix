{
  description = "Nix effect pod";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      pod-args = {
        nixEffectSource = ./.;
        pkgsSource = "${nixpkgs}";
        homeManagerSource = "${home-manager}";
      };
      development-pod = import ./development/pod.nix pod-args;
      librewolf-pod = import ./librewolf/pod.nix pod-args;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      pod.development = development-pod;
      pod.librewolf = librewolf-pod;
    };
}
