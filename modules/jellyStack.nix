{
  self,
  inputs,
  ...
}: let
  network = "jellyStack";
  baseDir = self.settings.disk.mntPoint;
in {
  flake.nixosModules.jellyStack = {pkgs, ...}: {
    virtualisation.oci-containers.backend = "docker";

    systemd.services.init-arrstack-network = {
      description = "Create internal Docker network for the Arr stack";
      after = ["network.target" "docker.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.docker}/bin/docker network create ${network}";
        ExecStop = "${pkgs.docker}/bin/docker network rm ${network}";
      };
    };

    virtualisation.oci-containers.containers = {
      "jellyfin" = {
        image = "jellyfin/jellyfin";
        autoStart = true;

        volumes = [
          "/logs/jellyfin:/log"
          "/cache/jellyfin:/cache"
          "${baseDir}/config/jellyfin:/config"
          "${baseDir}/movies:/movies"
          "${baseDir}/shows:/tv"
        ];
        ports = [
          "8096:8096/tcp"
        ];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
        };
      };

      "prowlarr" = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        volumes = ["${baseDir}/config/prowlarr:/config"];
        ports = ["9696:9696/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };

      "radarr" = {
        image = "lscr.io/linuxserver/radarr:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        volumes = [
          "${baseDir}/config/radarr:/config"
          "${baseDir}/movies:/movies"
          "${baseDir}/downloads:/downloads"
        ];
        ports = ["7878:7878/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };

      "sonarr" = {
        image = "lscr.io/linuxserver/sonarr:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        volumes = [
          "${baseDir}/config/sonarr:/config"
          "${baseDir}/shows:/tv"
          "${baseDir}/downloads:/downloads"
        ];
        ports = ["8989:8989/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };

      "qbittorrent" = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        volumes = [
          "${baseDir}/config/qbittorrent:/config"
          "${baseDir}/downloads:/downloads"
          "${baseDir}/movies:/movies"
          "${baseDir}/shows:/shows"
        ];
        ports = ["8080:8080/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };

      "flaresolverr" = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        ports = [
          "8191:8191/tcp"
        ];
        environment = {
          LOG_LEVEL = "info";
          TZ = "Europe/Amsterdam";
        };
      };

      "bazarr" = {
        image = "lscr.io/linuxserver/bazarr:latest";
        autoStart = true;
        extraOptions = ["--network=${network}"];
        volumes = [
          "${baseDir}/config/bazarr:/config"
          "${baseDir}/movies:/movies"
          "${baseDir}/shows:/tv"
        ];
        ports = ["6767:6767/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };

      "seerr" = {
        image = "ghcr.io/seerr-team/seerr:latest";
        autoStart = true;
        extraOptions = [
          "--network=${network}"
          "--init"
        ];
        volumes = ["${baseDir}/config/seerr:/app/config"];
        ports = ["5055:5055/tcp"];
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
          PUID = "1000";
          PGID = "1000";
        };
      };
    };
  };
}
