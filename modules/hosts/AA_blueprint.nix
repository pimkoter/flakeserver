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
      boot
      disko
      miscellaneous
      networking
      pkgs
      shell
      users

      # Host specific modules
    ];
  };
}
