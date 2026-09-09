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

      systemd.services.tailscale-autoconnect = {
        description = "Automatic connection to Tailscale";
        after = [
          "network-pre.target"
          "tailscale.service"
        ];
        wants = [
          "network-pre.target"
          "tailscale.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          # wait for tailscaled to settle
          sleep 2
          # check if we are already authenticated
          status=$(${config.services.tailscale.package}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)
          if [ "$status" = "Running" ]; then # if so, then do nothing
            exit 0
          fi
          # otherwise, authenticate
          ${config.services.tailscale.package}/bin/tailscale up --authkey=$(cat ${config.sops.secrets."tailscale/authkey".path})
        '';
      };
    };
}
