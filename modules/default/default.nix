{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.default = {
    imports = with self.nixosModules; [
      boot
      disko
      miscellaneous
      networking
      pkgs
      preservation
      users
    ];
  };
}
