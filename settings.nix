{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.settings = {
    imports = [./.options.nix];
  };

  settings = {
    alpha = {
      hostName = "alpha";
      ipAddr = "192.168.178.2";
      isPiHole = true;
    };

    beta = {
      hostName = "beta";
      ipAddr = "192.168.178.3";
    };

    gamma = {
      hostName = "gamma";
      ipAddr = "192.168.178.4";
    };

    delta = {
      hostName = "delta";
      ipAddr = "192.168.178.5";
    };
  };
}
