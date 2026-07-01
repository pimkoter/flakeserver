{
  self,
  inputs,
  ...
}: let
  name = "alpha";
in {
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      {settings.hostName = name;}
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
      settings

      # Host specific modules
      piHole
      unBound
    ];
  };
}
