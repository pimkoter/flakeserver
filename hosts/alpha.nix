{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      boot
      disko
      preservation
      users
    ];
  };
}
