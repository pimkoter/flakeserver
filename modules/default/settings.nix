{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.settings = {lib, ...}: {
    options = {
      settings =
        lib.mkOption {
        };
    };
  };
}
