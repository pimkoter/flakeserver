{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.drive2 = {
    fileSystems.${self.disk.mntPoint} = {
      device = self.disk.drive2;
      fsType = "ext4";
    };
  };
}
