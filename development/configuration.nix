## This file will be copied to the /etc/nixos directory of the image,
## so it cannot have dependencies out of pod-configs.
{
  nixEffectSource,
  homeManagerSource,
  ...
}:
let
  pod-configs = import ./pod-configs.nix;
  configuration = import "${nixEffectSource}/configuration.nix" {
    inherit (pod-configs)
      homeManagerConfigurationSource
      uname
      userHome
      ;
    inherit homeManagerSource;
  };
in
{
  imports = [ configuration ];

  programs = {
    zsh.enable = true;
  };
}
