{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
    ];
  };
}
