{
  self,
  inputs,
  ...
}: let
  name = "NAME";
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
    ];
  };
}
