{
  flake.nixosModules.caddy = {
    hostName,
    config,
    ...
  }: {
    services.caddy = {
      enable = true;
      virtualHosts."${hostName}.puber" = {
        extraConfig = ''
          reverse_proxy localhost:8080
        '';
      };
    };
    config.ports = [80 443];
  };
}
