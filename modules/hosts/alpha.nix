{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem {
    modules = with self; [
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
