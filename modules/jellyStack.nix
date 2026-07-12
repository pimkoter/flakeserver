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

    # Shared environment settings reused across all linuxserver.io containers
    commonEnv = {
      TZ = "Europe/Amsterdam";
      PUID = "1000";
      PGID = "1000";
    };

    # Safely load the dynamic keys if the file exists, otherwise use placeholders
    secretsFile = /etc/jellystack/secrets.nix;
    secrets =
      if builtins.pathExists secretsFile
      then import secretsFile
      else {
        prowlarrKey = "PLACEHOLDER";
        radarrKey = "PLACEHOLDER";
        sonarrKey = "PLACEHOLDER";
        lidarrKey = "PLACEHOLDER";
        seerrKey = "PLACEHOLDER";
        bazarrKey = "PLACEHOLDER";
      };
  in {
    imports = [
      inputs.declarr.nixosModules.default
    ];

    # All NixOS configurations must be wrapped cleanly inside this block
    config = {
      # Ensure the Docker network exists
      systemd.services.create-jellystack-network = {
        description = "Create jellystack docker network";
        after = ["network.target" "docker.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.docker}/bin/docker network create jellystack";
          ExecCondition = "${pkgs.bash}/bin/bash -c '! ${pkgs.docker}/bin/docker network inspect jellystack >/dev/null 2>&1'";
          RemainAfterExit = true;
        };
      };

      # Automated directory structure creation (Updated for Atomic Moves)
      systemd.tmpfiles.rules = [
        "d '${base}/config/jellyfin' 0755 1000 1000 -"
        "d '${base}/config/prowlarr' 0755 1000 1000 -"
        "d '${base}/config/radarr' 0755 1000 1000 -"
        "d '${base}/config/sonarr' 0755 1000 1000 -"
        "d '${base}/config/qbittorrent' 0755 1000 1000 -"
        "d '${base}/config/bazarr' 0755 1000 1000 -"
        "d '${base}/config/seerr' 0755 1000 1000 -"
        "d '${base}/config/lidarr' 0755 1000 1000 -"
        "d '${base}/data/media/movies' 0755 1000 1000 -"
        "d '${base}/data/media/shows' 0755 1000 1000 -"
        "d '${base}/data/media/music' 0755 1000 1000 -"
        "d '${base}/data/torrents' 0755 1000 1000 -"
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            jellyfin = {
              image = "jellyfin/jellyfin:latest";
              volumes = [
                "${base}/config/jellyfin:/config"
                "${base}/data/media:/media"
              ];
              ports = ["8096:8096"];
              extraOptions = [
                "--network=jellystack"
                "--device=/dev/dri:/dev/dri" # GPU Acceleration
              ];
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
                "${base}/data:/data" # Atomic Move Mount
              ];
              ports = ["7878:7878"];
              environment = commonEnv;
              extraOptions = ["--network=jellystack"];
            };
            sonarr = {
              image = "lscr.io/linuxserver/sonarr:latest";
              volumes = [
                "${base}/config/sonarr:/config"
                "${base}/data:/data" # Atomic Move Mount
              ];
              ports = ["8989:8989"];
              environment = commonEnv;
              extraOptions = ["--network=jellystack"];
            };
            qbittorrent = {
              image = "lscr.io/linuxserver/qbittorrent:latest";
              volumes = [
                "${base}/config/qbittorrent:/config"
                "${base}/data/torrents:/data/torrents"
              ];
              ports = ["8080:8080"];
              environment = commonEnv;
              extraOptions = ["--network=jellystack"];
            };
            bazarr = {
              image = "lscr.io/linuxserver/bazarr:latest";
              volumes = [
                "${base}/config/bazarr:/config"
                "${base}/data/media:/data/media"
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
                "${base}/data:/data" # Atomic Move Mount
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
              indexers = {
                "1337x" = {
                  enable = true;
                  implementation = "Torznab";
                  config = {
                    url = "https://1337x.to";
                  };
                };
                "YTS" = {
                  enable = true;
                  implementation = "Torznab";
                  config = {
                    url = "https://yts.mx";
                  };
                };
                "EZTV" = {
                  enable = true;
                  implementation = "Torznab";
                  config = {
                    url = "https://eztv.re";
                  };
                };
                "LimeTorrents" = {
                  enable = true;
                  implementation = "Torznab";
                  config = {
                    url = "https://www.limetorrents.info";
                  };
                };
              };
            };
            radarr = {
              url = "http://radarr:7878";
              apiKey = secrets.radarrKey;
              rootFolders = [{path = "/data/media/movies";}];
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
              rootFolders = [{path = "/data/media/shows";}];
              downloadClient."qBittorrent" = {
                enable = true;
                fields = {
                  host = "qbittorrent";
                  port = 8080;
                };
              };
            };
            lidarr = {
              url = "http://lidarr:8686";
              apiKey = secrets.lidarrKey;
              rootFolders = [{path = "/data/media/music";}];
              downloadClient."qBittorrent" = {
                enable = true;
                fields = {
                  host = "qbittorrent";
                  port = 8080;
                };
              };
            };
            jellyseerr = {
              url = "http://seerr:5055";
              apiKey = secrets.seerrKey;
            };
          };
        };
      };
      users.users.${config.admin.name}.extraGroups = ["docker"];
    };
  };
}
