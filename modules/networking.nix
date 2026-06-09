{
  inputs,
  self,
}: {
  flake.nixosModules.networking = {pkgs, ...}: {
    networking = {
      DHCP = false;
    };
  };
}
