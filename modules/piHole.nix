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
          misc.readOnly = true; # <-- Change to false when setting a new password
          api = {
            active = true;
            allowedOrigins = ["http://192.168.178.2" "https://192.168.178.2"];
          };

          webserver = {
            active = true;
            port = lib.mkForce "80";
            domain = lib.mkForce "192.168.178.2";
            api.pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$JmUiy69EGfJqy1/E9/o1Og==$KYi4l+qD/01Gj/J85mF9Ypg61eh2FylMYTVKqksDD/o="; # <-- to change: set misc.readOnly =false; run sudo pihole setpassword on the server, run sudo pihole-FTL --config webserver.api.pwhash and copy to api.pwhash !!DON'T FORGET TO SET MISC.READONLY TO FALSE AGAIN
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
              name = "home";
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
      pihole-ftl
    ];

    systemd.tmpfiles.rules = [
      # Silences a redundant error
      "f /etc/pihole/versions 0644 pihole pihole - -"
    ];
  };
}
