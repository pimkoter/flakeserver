{
  flake.nixosModules.vaultWarden =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          DOMAIN = "https://beta.taile21df4.ts.net";
          SIGNUPS_ALLOWED = true;
          ADMIN_TOKEN = "";
          LOG_FILE = "/var/lib/bitwarden_rs/access.log";
        };
      };

      environment.systemPackages = [
        pkgs.vaultwarden
      ];
    };
}
