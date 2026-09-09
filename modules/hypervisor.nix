{ self, inputs, ... }: {
  flake.nixosModules.hypervisor =
    { config, lib, ... }:
    {
      imports = [ inputs.microvm.nixosModules.host ];

      systemd.tmpfiles.rules = [
        "d /var/lib/microvm/persistent 0755 root root -"
        "d /var/lib/microvm/persistent/alpha 0755 root root -"
        "d /var/lib/microvm/persistent/beta 0755 root root -"
        "d /var/lib/microvm/persistent/gamma 0755 root root -"
        "d /var/lib/microvm/persistent/delta 0755 root root -"
      ];

      networking.bridges."br0".interfaces = [ config.settings.network.physicalInterface ];
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
