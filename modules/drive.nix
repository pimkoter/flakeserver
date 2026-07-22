{
  flake.nixosModules.mediaDrive = {config, ...}: {
    fileSystems.${config.disks.mntPoint} = {
      device = config.disks.media;
      fsType = "ext4";
    };

    boot.kernelParams = [
      # Disable UAS for JMicron USB bridge (vendor 152d, product 0583)
      "usb-storage.quirks=152d:0583:u"
    ];
  };
}
