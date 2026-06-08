{
  flake.nixosModules.piHole = {
    pkgs,
    hosts,
    ...
  }: let
    lib = pkgs.lib;
    inherit (builtins) attrNames;

    # Domain Declaration
    networkDomain = hosts.domain;

    # Host generation
    generatePiholeHosts = hostsData: let
      hostsOnly = builtins.removeAttrs hostsData ["domain"];
      caddyIp = hosts.caddy.ip;
    in
      lib.concatLists (
        lib.mapAttrsToList (
          hostName: hostConfig:
            if hostConfig ? ip
            then
              ["${caddyIp} ${hostName}.${networkDomain}"]
              ++ map (s: "${caddyIp} ${s}.${networkDomain}") (attrNames (hostConfig.services or {}))
            else []
        )
        hostsOnly
      );
  in {
    # Pi-hole FTL
    services.pihole-ftl = {
      enable = true;
      openFirewallDNS = true;
      openFirewallDHCP = true;
      settings = {
        dns = {
          upstreams = ["127.0.0.1#5335"];
          listeningMode = "all";
          domainNeeded = false;
          expandHosts = false;
          bogusPriv = true;
          queryLogging = true;
          localise = true;
          showDNSSEC = true;
          hosts = generatePiholeHosts hosts;
          domain = {
            name = networkDomain;
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
          router = "192.168.178.1";
          leaseTime = "6h";
          ipv6 = true;
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

      lists = [
        # Lists can be added via URL
        {
          url = "https://media.githubusercontent.com/media/zachlagden/Pi-hole-Optimized-Blocklists/main/lists/all_domains.txt";
          type = "block";
          enabled = true;
          description = "ZachLagden Blocklist";
        }
      ];
    };

    # -----------------------------
    # Pi-hole web UI (HTTP)
    # -----------------------------
    services.pihole-web = {
      enable = true;
      hostName = "127.0.0.1";
      ports = ["443s"];
    };

    config.ports = [80 443];
  };
}
