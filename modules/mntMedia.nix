{
  flake.nixosModules.mntMedia = {
    fileSystems."/media" = {
      device = "/dev/disk/by-uuid/af91dd32-6299-4eb5-982b-f111b7cca4e3";
      fsType = "ext4";
    };
  };
}
