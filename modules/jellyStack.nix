{
  flake.nixosModules.jellyStack = {pkgs, ...}: let
    network = "arrstack";
  in {
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
          "/config/jellyfin:/config"
          "/media/movies:/movies"
          "/media/shows:/tv"
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
        volumes = ["/config/prowlarr:/config"];
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
          "/config/radarr:/config"
          "/media/movies:/movies"
          "/media/downloads:/downloads"
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
          "/config/sonarr:/config"
          "/media/shows:/tv"
          "/media/downloads:/downloads"
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
          "/config/qbittorrent:/config"
          "/media/downloads:/downloads"
          "/media/movies:/movies"
          "/media/shows:/shows"
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
          "/config/bazarr:/config"
          "/media/movies:/movies"
          "/media/shows:/tv"
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
        volumes = ["/config/seerr:/app/config"];
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
