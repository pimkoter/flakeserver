{
  self,
  inputs,
}: {
  flake.nixosModules.unBound = {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = ["127.0.0.1" self.settings.networking.nameServers];
          port = 5335;
          prefetch = "yes";
          do-ip6 = "no";
          access-control = [
            "127.0.0.0/8 allow"
            "192.168.178.0/24 allow"
          ];
        };
      };
    };
  };
}
