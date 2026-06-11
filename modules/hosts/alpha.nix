{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      default
    ];
  };
}
