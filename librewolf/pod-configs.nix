{
  podName = "librewolf-test-pod";
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  uname = "dev";
  userHome = "/home/dev";
  etcActivation = true;
  homeActivation = true;
}
