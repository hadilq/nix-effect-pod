{
  podName = "dev-test-pod";
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  uname = "dev";
  userHome = "/home/dev";
  homeActivation = true;
}
