{
  flake.nixosModules.mediaDrive = {config, ...}: {
    fileSystems.${config.disks.mntPoint} = {
      device = config.disks.media;
      fsType = "ext4";
    };
  };
}
