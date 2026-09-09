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
        useNetworkd = true; # Use networkd for both host and guests for consistency
        networkmanager.enable = false;
      };

      # Use systemd-networkd for static IPs and Gateways
      systemd.network = {
        enable = true;
        networks."40-ethernet" = {
          name = if config.settings.hostName == "omega" then "br0" else "eth0";
          address = [
            "${
              if config.settings.hostName == "omega" then
                "192.168.178.10/24"
              else
                "${config.settings.hosts.${config.settings.hostName}.ipAddr}/24"
            }"
          ];
          gateway = [ config.settings.admin.routerIp ];
          dns = config.networking.nameservers;
        };
      };

      services = {
        enable = true;
        trustedInterfaces = [ "tailscale0" ] ++ (lib.optional (config.settings.hostName == "omega") "br0");
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
