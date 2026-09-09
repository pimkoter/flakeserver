{ inputs, config, ... }: {
  imports = [ inputs.microvm.nixosModules.microvm ];
  microvm = {
    hypervisor = "qemu";
    vcpu = 2;
    mem = 4096;
    interfaces = [
      {
        type = "bridge";
        id = "vm-${config.settings.hostName}";
        bridge = "br0";
        mac = "02:00:00:00:00:04";
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
      {
        tag = "media";
        source = config.settings.disks.mntPoint;
        mountPoint = config.settings.disks.mntPoint;
      }
    ];
  };
}
