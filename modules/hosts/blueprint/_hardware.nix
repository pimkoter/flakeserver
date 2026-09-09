{ inputs, config, ... }: {
  imports = [ inputs.microvm.nixosModules.microvm ];
  microvm = {
    hypervisor = "qemu";
    vcpu = 1;
    mem = 1024;
    interfaces = [
      {
        type = "bridge";
        id = "vm-${config.settings.hostName}";
        bridge = "br0";
        mac = "02:00:00:00:00:01";
      }
    ];
    shares = [
      {
        tag = "ro-nix-store";
        source = "/nix/store";
        mountPoint = "/nix/store";
      }
      {
        tag = "persistent";
        source = "/var/lib/microvm/persistent/${config.settings.hostName}";
        mountPoint = "/var/lib";
      }
    ];
  };
}
