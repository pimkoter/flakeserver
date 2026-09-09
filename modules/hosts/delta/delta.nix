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
    specialArgs = {
      inherit inputs self;
    };
    modules =
      with self.nixosModules;
      [
        { settings.hostName = name; }
        # Default modules
        boot
        miscellaneous
        networking
        pkgs
        shell
        users
        settings
        secrets
        guest-common

        # Host specific modules
        exitNode
        ./_hardware.nix
      ];
  };
}
