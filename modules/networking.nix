{
  flake.nixosModules.networking = {
    settings,
    hostName,
    lib,
    config,
    ...
  }: let
    cfg = {
      iface = "ens18";
      prefixLength = 24;
      gateway = settings.ip.general.gateway;
      domain = settings.admin.domain;
      ipAddress = settings.hostName.ip;
    };
  in {
    services = {
      resolved.enable = lib.mkForce false;
      tailscale = {
        enable = true;
        extraUpFlags = [
          "--operator=${settings.admin.name}"
          "--ssh"
        ];
      };
    };

    networking = {
      inherit hostName;
      useDHCP = false;
      networkmanager.enable = false;
      domain = cfg.domain;
      nameservers = [settings.general.nameServer];
      defaultGateway = cfg.gateway;
      interfaces.${cfg.iface}.ipv4.addresses = [
        {
          address = cfg.ipAddress;
          inherit (cfg) prefixLength;
        }
      ];
      firewall = {
        enable = true;
        trustedInterfaces = [cfg.iface "tailscale0"];
        allowedUDPPorts = config.ports;
        allowedTCPPorts = config.ports;
      };
    };
  };
}
