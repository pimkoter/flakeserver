{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # GENERATED!

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
