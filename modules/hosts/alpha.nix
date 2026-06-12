{
  self,
  inputs,
  ...
}: let
  name = "alpha";
in {
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      # Default modules
      autoUpgrade
      boot
      disko
      miscellaneous
      networking
      pkgs
      preservation
      shell
      users

      # Host specific modules
      piHole
      unBound
    ];
  };
}
