{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.drive2 = {config, ...}: {
    fileSystems.${config.disks.mntPoint} = {
      device = config.disks.drive2;
      fsType = "ext4";
    };
  };
}
