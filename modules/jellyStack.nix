{
  self,
  inputs,
  config,
  pkgs,
  ...
}: let
  base = config.disks.mntPoint;

  # Shared environment settings reused across all linuxserver.io containers
  commonEnv = {
    TZ = "Europe/Amsterdam";
    PUID = "1000";
    PGID = "1000";
  };

  # Load dynamically scraped keys safely if the file exists, otherwise use placeholders
  secretsFile = /etc/jellystack/secrets.nix;
  secrets =
    if builtins.pathExists secretsFile
    then import secretsFile
    else {
      prowlarrKey = "PLACEHOLDER";
      radarrKey = "PLACEHOLDER";
      sonarrKey = "PLACEHOLDER";
    };
in {
  imports = [
    inputs.declarr.nixosModules.default
  ];

  # Automated directory structure creation
  systemd.tmpfiles.rules = [
    "d '${base}/config/jellyfin' 0755 1000 1000 -"
    "d '${base}/config/prowlarr' 0755 1000 1000 -"
    "d '${base}/config/radarr' 0755 1000 1000 -"
    "d '${base}/config/sonarr' 0755 1000 1000 -"
    "d '${base}/config/qbittorrent' 0755 1000 1000 -"
    "d '${base}/config/bazarr' 0755 1000 1000 -"
    "d '${base}/config/seerr' 0755 1000 1000 -"
    "d '${base}/config/lidarr' 0755 1000 1000 -"
    "d '${base}/movies' 0755 1000 1000 -"
    "d '${base}/shows' 0755 1000 1000 -"
    "d '${base}/music' 0755 1000 1000 -"
    "d '${base}/downloads' 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:latest";
        volumes = [
          "${base}/config/jellyfin:/config"
          "${base}/movies:/movies"
          "${base}/shows:/tv"
          "${base}/music:/music"
        ];
        ports = ["8096:8096"];
        extraOptions = ["--network=jellystack"];
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        volumes = ["${base}/config/prowlarr:/config"];
        ports = ["9696:9696"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        volumes = [
          "${base}/config/radarr:/config"
          "${base}/movies:/movies"
          "${base}/downloads:/downloads"
        ];
        ports = ["7878:7878"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        volumes = [
          "${base}/config/sonarr:/config"
          "${base}/shows:/tv"
          "${base}/downloads:/downloads"
        ];
        ports = ["8989:8989"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        volumes = [
          "${base}/config/qbittorrent:/config"
          "${base}/downloads:/downloads"
        ];
        ports = ["8080:8080"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:latest";
        volumes = [
          "${base}/config/bazarr:/config"
          "${base}/movies:/movies"
          "${base}/shows:/tv"
        ];
        ports = ["6767:6767"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
      seerr = {
        image = "ghcr.io/seerr-team/seerr:latest";
        volumes = ["${base}/config/seerr:/app/config"];
        ports = ["5055:5055"];
        environment = {TZ = "Europe/Amsterdam";};
        extraOptions = ["--network=jellystack"];
      };
      lidarr = {
        image = "lscr.io/linuxserver/lidarr:latest";
        volumes = [
          "${base}/config/lidarr:/config"
          "${base}/music:/music"
          "${base}/downloads:/downloads"
        ];
        ports = ["8686:8686"];
        environment = commonEnv;
        extraOptions = ["--network=jellystack"];
      };
    };
  };

  services.declarr = {
    enable = true;
    config = {
      prowlarr = {
        url = "http://prowlarr:9696";
        apiKey = secrets.prowlarrKey;
      };

      radarr = {
        url = "http://radarr:7878";
        apiKey = secrets.radarrKey;
        downloadClient."qBittorrent" = {
          enable = true;
          fields = {
            host = "qbittorrent";
            port = 8080;
          };
        };
      };

      sonarr = {
        url = "http://sonarr:8989";
        apiKey = secrets.sonarrKey;
        downloadClient."qBittorrent" = {
          enable = true;
          fields = {
            host = "qbittorrent";
            port = 8080;
          };
        };
      };
    };
  };

  users.users.${config.admin.name}.extraGroups = ["docker"];
}
