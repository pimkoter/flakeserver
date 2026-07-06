{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.jellyStack = {
    config,
    pkgs,
    ...
  }: let
    base = config.disks.mntPoint;
  in {
    systemd.tmpfiles.rules = [
      "d '${base}/config/jellyfin' 0755 1000 1000 -"
      "d '${base}/config/prowlarr' 0755 1000 1000 -"
      "d '${base}/config/radarr' 0755 1000 1000 -"
      "d '${base}/config/sonarr' 0755 1000 1000 -"
      "d '${base}/config/qbittorrent' 0755 1000 1000 -"
      "d '${base}/config/bazarr' 0755 1000 1000 -"
      "d '${base}/config/seerr' 0755 1000 1000 -"
    ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        jellyfin = {
          image = "jellyfin/jellyfin";
          volumes = ["${base}/config/jellyfin:/config" "${base}/movies:/movies" "${base}/shows:/tv"];
          ports = ["8096:8096"];
        };
        prowlarr = {
          image = "lscr.io/linuxserver/prowlarr:latest";
          volumes = ["${base}/config/prowlarr:/config"];
          ports = ["9696:9696"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
        radarr = {
          image = "lscr.io/linuxserver/radarr:latest";
          volumes = ["${base}/config/radarr:/config" "${base}/movies:/movies" "${base}/downloads:/downloads"];
          ports = ["7878:7878"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
        sonarr = {
          image = "lscr.io/linuxserver/sonarr:latest";
          volumes = ["${base}/config/sonarr:/config" "${base}/shows:/tv" "${base}/downloads:/downloads"];
          ports = ["8989:8989"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
        qbittorrent = {
          image = "lscr.io/linuxserver/qbittorrent:latest";
          volumes = ["${base}/config/qbittorrent:/config" "${base}/downloads:/downloads" "${base}/movies:/movies" "${base}/shows:/shows"];
          ports = ["8080:8080"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
        bazarr = {
          image = "lscr.io/linuxserver/bazarr:latest";
          volumes = ["${base}/config/bazarr:/config" "${base}/movies:/movies" "${base}/shows:/tv"];
          ports = ["6767:6767"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
        seerr = {
          image = "ghcr.io/seerr-team/seerr:latest";
          volumes = ["${base}/config/seerr:/app/config"];
          ports = ["5055:5055"];
          environment = {
            TZ = "Europe/Amsterdam";
            PUID = "1000";
            PGID = "1000";
          };
        };
      };
    };

    users.users.${config.admin.name} = {
      extraGroups = ["docker"];
    };
  };
}
