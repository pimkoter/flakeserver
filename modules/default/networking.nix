{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    networking.hostName = "nixos";
    services.openssh.enable = true;
  };
}
