{ inputs, ... }: {
  flake.nixosModules.guest-common = { ... }: {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      inputs.microvm.nixosModules.microvm
    ];

    # Common guest settings
    services.qemuGuest.enable = true;
    networking.useNetworkd = true;
  };
}
