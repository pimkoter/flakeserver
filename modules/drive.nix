{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.drive2 = {
    fileSystems.${self.nixosModules.settings.disk.mntPoint} = {
      device = self.nixosModules.settings.disk.drive2;
      fsType = "ext4";
    };
  };
}
