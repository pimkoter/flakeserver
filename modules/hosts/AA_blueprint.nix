{
  self,
  inputs,
  ...
}: let
  name = "NAME";
in {
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      default
    ];
  };
}
