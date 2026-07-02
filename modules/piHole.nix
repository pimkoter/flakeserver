{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.piHole = {
    config,
    pkgs,
    lib,
    ...
  }: {
    services = {
      pihole-web = {
        enable = true;
        ports = ["80r" "443s"];
      };

      pihole-ftl = {
        enable = true;
        openFirewallDNS = true;
        openFirewallDHCP = true;
        openFirewallWebserver = true;

        settings = {
          api = {
            active = true;
            allowedOrigins = ["http://192.168.178.2" "https://192.168.178.2"];
          };

          webserver = {
            active = true;
            port = "80";
            domain = "192.168.178.2";
            api.pwhash = "";
          };

          dns = {
            upstreams = ["127.0.0.1#5335"];
            listeningMode = "all";
            domainNeeded = false;
            expandHosts = false;
            bogusPriv = true;
            queryLogging = true;
            localise = true;
            showDNSSEC = true;
            domain = {
              name = "puber";
              local = true;
            };
            cache = {
              size = 10000;
              optimizer = 3600;
              upstreamBlockedTTL = 86400;
              rrtype = "ANY";
            };
            blocking = {
              active = true;
              mode = "NULL";
              edns = "TEXT";
            };
            specialDomains = {
              mozillaCanary = true;
              iCloudPrivateRelay = true;
              designatedResolver = true;
            };
            rateLimit = {
              burst = 1000;
              windowSeconds = 30;
            };
          };
          dhcp = {
            active = true;
            start = "192.168.178.50";
            end = "192.168.178.254";
            router = config.admin.routerIp;
            leaseTime = "6h";
            ipv6 = false;
            rapidCommit = true;
          };
          ntp = {
            ipv4.active = true;
            ipv6.active = true;
            sync = {
              active = true;
              server = "pool.ntp.org";
              interval = 3600;
              count = 8;
              rtc.utc = true;
            };
          };
          resolver = {
            resolveIPv4 = true;
            resolveIPv6 = true;
            macNames = true;
            networkNames = true;
            refreshNames = "IPV4_ONLY";
          };
          database = {
            DBimport = true;
            maxDBdays = 91;
            DBinterval = 60;
            useWAL = true;
            network = {
              parseARPcache = true;
              expire = 91;
            };
          };
          misc = {
            privacylevel = 0;
            nice = -10;
            normalizeCPU = true;
            check = {
              load = true;
              shmem = 90;
              disk = 90;
            };
          };
        };
        lists = [];
      };
    };
    systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = "/var/lib/pihole/admin_password.txt";
    environment.systemPackages = with pkgs; [
      pihole
    ];
  };
}
