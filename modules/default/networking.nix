{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    networking = {
      useDHCP = false;
      nameservers = self.settings.networking.nameservers;
    };
    services = {
      networkmanager.enable = false;
      openssh.enable = true;
      tailscale = {
        enable = true;
        useRoutingFeatures = "client";
        extraUpFlags = ["--ssh" "--operator=${self.settings.admin.name}"];
      };
      fail2ban = {
        enable = true;
        bantime = "10m";
        bantime-increment.factor = "6";
      };
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
      };
      resolved.enable = false;
    };
  };
}
