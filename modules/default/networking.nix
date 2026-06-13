{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {config, ...}: {
    networking = {
      useDHCP = false;
      networkmanager.enable = false;
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
      };
    };
    services = {
      openssh.enable = true;
      tailscale = {
        enable = true;
        useRoutingFeatures = "client";
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
