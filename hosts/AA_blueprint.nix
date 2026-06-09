{
  self,
  inputs,
  ...
}: let
  hostName = "blueprint";
in {
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
    ];
  };
}
