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
      networking
      disko
      caddy
      common

      # Custom
      piHole
      unBound
    ];
  };
}
