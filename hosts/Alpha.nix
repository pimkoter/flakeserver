{
  inputs,
  self,
  hostName,
  ...
}: {
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      hostName = "Alpha";
    };

    modules = with self.nixosModules; [
      # Default
      autoUpgrade
      autoGarbage
      preservation
      networking
      caddy
      common

      # Custom
      piHole
      unBound
    ];
  };
}
