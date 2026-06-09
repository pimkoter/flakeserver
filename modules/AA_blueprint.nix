{
  inputs,
  self,
  ...
}: let
  module = "blueprint";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    # Your module here
  };
}
