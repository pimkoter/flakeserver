{
  flake.nixosModules.networking =
    {
      config,
      lib,
      pkgs,
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
        useNetworkd = true;
        networkmanager.enable = false;

        firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ] ++ (lib.optional (config.settings.hostName == "omega") "br0");
        };
      };

      services.resolved.enable = true;

      systemd.network = {
        enable = true;

        netdevs = lib.mkIf (config.settings.hostName == "omega") {
          "20-br0" = {
            netdevConfig = {
              Name = "br0";
              Kind = "bridge";
              # Inherit MAC from physical card to avoid router confusion
              MACAddress = "none";
            };
          };
        };

        networks."30-physical" = lib.mkIf (config.settings.hostName == "omega") {
          matchConfig.Name = [ config.settings.network.physicalInterface "en*" "eth*" ];
          networkConfig.Bridge = "br0";
          linkConfig.RequiredForOnline = "no";
        };

        networks."40-ethernet" = {
          matchConfig.Name = if config.settings.hostName == "omega" then "br0" else "eth0";
          address = [
            "${
              if config.settings.hostName == "omega" then
                "192.168.178.10/24"
              else
                "${config.settings.hosts.${config.settings.hostName}.ipAddr}/24"
            }"
          ];
          routes = [
            {
              routeConfig = {
                Gateway = config.settings.admin.routerIp;
                Metric = 10; # Lower metric wins (Bridge > Wifi)
              };
            }
          ];
          dns = config.networking.nameservers ++ [ "1.1.1.1" ];
          linkConfig.RequiredForOnline = "routable";
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
      };
    };
}
