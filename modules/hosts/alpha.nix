{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.boot
      self.nixosModules.disko
      self.nixosModules.miscellaneous
      self.nixosModules.networking
      self.nixosModules.pkgs
      self.nixosModules.preservation
      self.nixosModules.users
    ];
  };
}
