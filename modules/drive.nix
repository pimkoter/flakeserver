{
  flake.nixosModules.mediaDrive = { config, ... }: {
    fileSystems.${config.settings.disks.mntPoint} = {
      device = config.settings.disks.media;
      fsType = "ext4";
    };

    boot.kernelParams = [
      # Disable UAS for JMicron USB bridge (vendor 152d, product 0583)
      "usb-storage.quirks=152d:0583:u"
    ];
  };
}
