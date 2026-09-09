{ config, lib, ... }: {
  flake.nixosModules.proxy = { config, lib, ... }: {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "pihole.puber" = {
          locations."/" = {
            proxyPass = "http://${config.settings.hosts.alpha.ipAddr}:80";
          };
        };
        "immich.puber" = {
          locations."/" = {
            proxyPass = "http://${config.settings.hosts.beta.ipAddr}:2283";
          };
        };
        "vault.puber" = {
          locations."/" = {
            proxyPass = "http://${config.settings.hosts.beta.ipAddr}:80";
          };
        };
        "jellyfin.puber" = {
          locations."/" = {
            proxyPass = "http://${config.settings.hosts.gamma.ipAddr}:8096";
          };
        };
        "hass.puber" = {
          locations."/" = {
            proxyPass = "http://${config.settings.hosts.beta.ipAddr}:8123";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
