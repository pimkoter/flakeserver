{ inputs, config, ... }: {
  flake.nixosModules.guest-common = { ... }: {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      inputs.microvm.nixosModules.microvm
    ];

    # Enable recommended microvm network management
    microvm.network.enable = true;

    # Share the host's Nix store using VirtIO-FS
    microvm.shares = [ {
      proto = "virtiofs";
      tag = "ro-nix-store";
      source = "/nix/store";
      mountPoint = "/nix/store";
    } ];

    networking.useNetworkd = true;
    networking.usePredictableInterfaceNames = false;
    services.qemuGuest.enable = true;

    # Disable garbage collection in guests to prevent host store corruption
    nix.gc.automatic = false;
    nix.settings.auto-optimise-store = false;
  };
}
