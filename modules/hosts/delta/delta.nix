{
  self,
  inputs,
  ...
}:
let
  name = "delta";
in
{
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      { settings.hostName = name; }
      # Default modules
      boot
      disko
      miscellaneous
      networking
      pkgs
      shell
      users
      settings

      # Host specific modules
      exitNode
    ];
  };
}
