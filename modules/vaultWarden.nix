{
  flake.nixosModules.vaultWarden = {config, ...}: {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite"; # Perfect for personal/small team use
      backupDir = "/var/local/vaultwarden/backup";
      environmentFile = "/etc/vaultwarden.env";

      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "http://vaultwarden.puber";
        SIGNUPS_ALLOWED = true;
      };
    };

    environment.etc."vaultwarden.env" = {
      text = ''
        ADMIN_TOKEN=''${argon2id}''$v=19''$m=65540,t=3,p=4''$1XEvCSWNOGOmKMyzzIk1wxeqQHfsdiixpZObH1KIE+I''$uPAGDGTz695T/hwRGxbK3L5a6UtK0qZjxQffPyd2gxc
      '';
      mode = "0400"; # Read-only
      user = "vaultwarden";
      group = "vaultwarden";
    };

    config.ports = [config.ROCKE_PORT];
  };
}
