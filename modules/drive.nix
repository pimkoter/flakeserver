{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.drive = {
    fileSystems.${self.disk.mntPoint} = {
      device = self.disk.drive;
      fsType = "ext4";
    };
  };
}
