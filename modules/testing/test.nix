{ self, ... }: {
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      # =========================================================================
      # 1. VM TESTING STUB MODULE
      # =========================================================================
      # Overrides hardware, bootloader, disko, & provides mock option defaults
      stubModule = { lib, ... }: {
        boot.loader.grub.enable = lib.mkForce false;
        boot.loader.systemd-boot.enable = lib.mkForce true;
        documentation.enable = lib.mkForce false;
        networking.useDHCP = lib.mkDefault true;
        networking.firewall.enable = lib.mkDefault true;

        # Mock custom option defaults if modules depend on custom options (e.g. config.disks)
        options.disks = {
          mntPoint = lib.mkOption {
            type = lib.types.str;
            default = "/mnt/media";
          };
          media = lib.mkOption {
            type = lib.types.str;
            default = "/dev/vdb";
          };
        };
      };

      # =========================================================================
      # 2. HELPER FUNCTIONS & SCANNER ENGINE
      # =========================================================================
      getNixFiles =
        dir:
        let
          entries = builtins.readDir dir;
        in
        lib.mapAttrsToList (name: _: lib.removeSuffix ".nix" name) (
          lib.filterAttrs (
            name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
          ) entries
        );

      # Generator for single-service unit tests
      mkServiceTest =
        {
          name,
          modules ? [ ],
          testScript,
        }:
        pkgs.testers.runNixOSTest {
          inherit name testScript;
          nodes.server = { ... }: {
            imports = [
              stubModule
            ]
            ++ modules;
            networking.hostName = name;
          };
        };

      # =========================================================================
      # 3. DYNAMICALLY GENERATED SERVICE TESTS
      # =========================================================================
      # Grabs all registered modules from self.nixosModules automatically!
      autoServiceTests = lib.mapAttrs' (moduleName: moduleAttrs: {
        name = "test-service-${moduleName}";
        value = mkServiceTest {
          name = moduleName;
          modules = [ moduleAttrs ];
          testScript = ''
            server.start()
            server.wait_for_unit("multi-user.target")
          '';
        };
      }) self.nixosModules;

      # =========================================================================
      # 4. CUSTOM OVERRIDES FOR COMPLEX SERVICES
      # =========================================================================
      customServiceTests = {
        test-service-immich = mkServiceTest {
          name = "immich-smoke";
          modules = [ self.nixosModules.immich ];
          testScript = ''
            server.start()
            server.wait_for_unit("immich-server.service")
            server.wait_for_open_port(2283)
            server.succeed("curl -f http://localhost:2283/api/server-info/ping")
          '';
        };

        test-service-vaultWarden = mkServiceTest {
          name = "vaultwarden-smoke";
          modules = [ self.nixosModules.vaultWarden ];
          testScript = ''
            server.start()
            server.wait_for_unit("vaultwarden.service")
            server.wait_for_open_port(8000)
            server.succeed("curl -s http://localhost:8000/ | grep -i vaultwarden")
          '';
        };
      };

      unitTests = autoServiceTests // customServiceTests;

      # =========================================================================
      # 5. DYNAMICALLY GENERATED HOST TESTS (./modules/hosts/*.nix)
      # =========================================================================
      hostTests =
        let
          hostNames = getNixFiles ./../hosts;
        in
        lib.listToAttrs (
          map (name: {
            name = "test-host-${name}";
            value = pkgs.testers.runNixOSTest {
              name = "host-${name}-integration";
              nodes.${name} = { ... }: {
                imports = [
                  ./../hosts/${name}.nix
                  stubModule
                ];
              };
              testScript = ''
                ${name}.start()
                ${name}.wait_for_unit("multi-user.target")
              '';
            };
          }) hostNames
        );

      # =========================================================================
      # 6. STATIC CODE LINTING (Statix & Deadnix)
      # =========================================================================
      staticChecks = {
        statix =
          pkgs.runCommand "statix-check"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              # Copy flake source into working dir so it's not scanned as a /nix/store/ path
              cp -r ${self}/* .

              # Run statix on local files
              statix check .

              mkdir $out
            '';

        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              # Copy flake source into working dir
              cp -r ${self}/* .

              # Run deadnix on local files (fails if dead code exists)
              deadnix --fail .

              mkdir $out
            '';
      };
    in
    {
      # Expose VM tests and static linter checks to `nix flake check`
      checks = unitTests // hostTests // staticChecks;
    };
}
