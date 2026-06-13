{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    networking = {
      useDHCP = false;
      nameservers = self.nixosModules.settings.networking.nameservers;
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
        extraUpFlags = ["--ssh" "--operator=${self.nixosModules.settings.admin.name}"];
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
