{
  self,
  inputs,
  ...
}: let
  hostName = "alpha";
in {
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      boot
      disko
      preservation
      users
    ];
  };
}
