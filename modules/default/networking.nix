{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.networking = {
    settings,
    lib,
    ...
  }: {
    networking = {
      useDHCP = false;
      nameservers = settings.networking.nameservers;
    };
    services = {
      networkmanager.enable = false;
      openssh = {
        enable = true;
      };
      tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
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
