{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    networking = {
      useDHCP = false;
      nameservers = self.settings.networking.nameservers;
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
      };
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
      resolved.enable = false;
    };
  };
}
