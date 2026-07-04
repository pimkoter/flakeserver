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
        misc.readOnly = false;

        settings = {
          api = {
            active = true;
            allowedOrigins = ["http://192.168.178.2" "https://192.168.178.2"];
          };

          webserver = {
            active = true;
            port = lib.mkForce "80";
            domain = lib.mkForce "192.168.178.2";
            api.pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$38d54e5d9fb97f6bdeb5887d3e990cd5626f0b4b2c6b57bcd43c044d5435135052a0e0d74b0522588869a46bfc2d4e7d7cb558b0ec3bf73b073ca85c4e77dbda";
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
    environment.systemPackages = with pkgs; [
      pihole
    ];
  };
}
