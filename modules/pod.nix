{
  system,
  nixEffectSource,
  pkgsSource,
  homeManagerSource,
  podName,
  nixosConfigurationSource,
  homeManagerConfigurationSource,
  uname ? "dev",
  userHome ? "/home/dev",
  channelsList ? [ ],
  extraSpecialArgs ? { },
  etcActivation ? false,
  homeActivation ? false,
}:
let
  image = (
    import "${nixEffectSource}/pod.nix" {
      name = podName;
      extraSpecialArgs = extraSpecialArgs // {
        podConfigs = {
          inherit
            nixEffectSource
            nixosConfigurationSource
            homeManagerSource
            homeManagerConfigurationSource
            uname
            userHome
            ;
        };
      };
      inherit
        system
        nixEffectSource
        pkgsSource
        homeManagerSource
        uname
        userHome
        channelsList
        etcActivation
        homeActivation
        ;
    }
  );
in
image
