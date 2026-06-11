{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.boot
      self.disko
      self.miscellaneous
      self.networking
      self.pkgs
      self.preservation
      self.users
    ];
  };
}
