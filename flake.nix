{
  description = "Nix effect pod";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      path = ./.;
      pod-configs = {
        system = "x86_64-linux";
        nixEffectSource = ./.;
        pkgsSource = "${nixpkgs}";
        homeManagerSource = "${home-manager}";
      };
      development-pod = import "${path}/modules/pod.nix" (pod-configs // import ./development/pod-configs.nix);
      librewolf-pod = import "${path}/modules/pod.nix" (pod-configs // import ./librewolf/pod-configs.nix);
    in
    {
      inherit path;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      pod.development = development-pod;
      pod.librewolf = librewolf-pod;
    };
}
