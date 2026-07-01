{
  flake.nixosModules.homeAssistant = {
    virtualisation.oci-containers = {
      backend = "docker";
      containers.homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        volumes = [
          "home-assistant-config:/config"
          "/run/dbus:/run/dbus:ro"
        ];
        environment = {
          TZ = "America/New_York";
        };
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
      };
    };
    networking.firewall.allowedTCPPorts = [8123];
  };
}
