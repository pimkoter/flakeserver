{inputs, ...}: {
  flake.nixosModules.zennotes = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.zennotes.nixosModules.server
    ];

    # Configure the ZenNotes server
    services.zennotes = {
      enable = true;
      port = 7878;
      bindAddress = "0.0.0.0";
      openFirewall = true;
      dataDir = "/var/lib/zennotes";
      vaultPath = "/var/lib/zennotes/vault";

      extraEnvironment = {
        ZENNOTES_AUTH_TOKEN = "12345";
        ZENNOTES_PERSIST_SESSIONS = "1";
      };
    };
  };
}
