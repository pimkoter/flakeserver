{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    config,
    lib,
    ...
  }: {
    networking = {
      hostName = config.hosts.${config.settings.hostName}.hostName;
      useDHCP = false;
      networkmanager.enable = false;
      defaultGateway = config.admin.routerIp;
      interfaces.ens18.ipv4.addresses = [
        {
          address = config.hosts.${config.settings.hostName}.ipAddr;
          prefixLength = 24;
        }
      ];
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
      };
    };

    services = {
      openssh.enable = true;
      tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
        extraUpFlags = ["--ssh" "--operator=${config.admin.name}"];
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
