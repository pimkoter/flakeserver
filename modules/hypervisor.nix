{ self, inputs, ... }: {
  flake.nixosModules.hypervisor =
    { config, lib, ... }:
    {
      imports = [ inputs.microvm.nixosModules.host ];

      networking.bridges."br0".interfaces = [ "ens18" ];
      networking.interfaces."br0".ipv4.addresses = [
        {
          address = "192.168.178.10";
          prefixLength = 24;
        }
      ];

      microvm.vms = {
        alpha = {
          flake = self;
        };
        beta = {
          flake = self;
        };
        gamma = {
          flake = self;
        };
        delta = {
          flake = self;
        };
      };
    };
}
