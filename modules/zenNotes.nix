{inputs, ...}: {
  flake.nixosModules.zennotes = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-server
    ];
  };
}
