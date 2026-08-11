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
          DOMAIN = "https://vaultwarden.taile21df4.ts.net";
          SIGNUPS_ALLOWED = true;
          ADMIN_TOKEN = "";
        };
      };

      environment.systemPackages = [
        pkgs.vaultwarden
      ];

      services.tailscale = {
        serve = {
          enable = true;
          services.vaultwarden = {
            endpoints = {
              "tcp:443" = "http://127.0.0.1:8222";
            };
          };
        };
      };
    };
}
