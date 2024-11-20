let
  pod-configs = import ./pod-configs.nix;
  image = (import ../pod.nix {
    inherit (pod-configs) system pkgsSource name nixosConfigurationSource
      channelsList podProfileDirPath username userHome homeActivation;
  });
in
image
