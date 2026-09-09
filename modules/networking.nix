{
  flake.nixosModules.networking =
    {
      config,
      lib,
      ...
    }:
    {
      networking = {
        hostName =
          if lib.hasAttr config.settings.hostName config.settings.hosts then
            config.settings.hosts.${config.settings.hostName}.hostName
          else
            config.settings.hostName;

        useDHCP = false;
        networkmanager.enable = false;
        defaultGateway = {
          address = config.settings.admin.routerIp;
          interface = if config.settings.hostName == "omega" then "br0" else "eth0";
        };
        interfaces =
          if config.settings.hostName == "omega" then
            {
              br0.ipv4.addresses = [
                {
                  address = "192.168.178.10";
                  prefixLength = 24;
                }
              ];
            }
          else
            {
              eth0.ipv4.addresses = [
                {
                  address = config.settings.hosts.${config.settings.hostName}.ipAddr;
                  prefixLength = 24;
                }
              ];
            };
        firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
        };
      };

      services = {
        openssh.enable = true;
        tailscale = {
          enable = true;
          openFirewall = true;
          useRoutingFeatures = lib.mkDefault "client";
          extraUpFlags = [
            "--ssh"
            "--operator=${config.settings.admin.name}"
          ];
        };
        fail2ban = {
          enable = true;
          bantime = "10m";
          bantime-increment.factor = "6";
        };
        resolved.enable = false;
      };
    };
}
