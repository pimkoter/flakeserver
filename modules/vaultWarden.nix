{
  flake.nixosModules.vaultWarden = {
    config,
    pkgs,
    ...
  }: {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.example.org";
        SIGNUPS_ALLOWED = true;
        ADMIN_TOKEN = "";
        LOG_FILE = "/var/lib/bitwarden_rs/access.log";
      };
    };

    # The CLI tool
    environment.systemPackages = [
      pkgs.vaultwarden
    ];
  };
}
