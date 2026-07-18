{inputs, ...}: {
  flake.nixosModules.zennotes = {
    config,
    lib,
    pkgs,
    ...
  }: let
    zennotes-pkg = inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-server;
    port = 8080;
    vaultPath = "/home/${config.admin.name}/notes";
  in {
    users.users.zennotes = {
      isSystemUser = true;
      group = "zennotes";
    };

    users.groups.zennotes = {};
    systemd.services.zennotes = {
      description = "ZenNotes Server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        ExecStart = "${zennotes-pkg}/bin/zennotes-server";
        User = "zennotes";
        Group = "zennotes";

        # --- Environment Variables ---
        # We use these to override the defaults
        Environment = [
          "PORT=${toString port}"
          "VAULT_PATH=${vaultPath}"
          # Bind to 0.0.0.0 so other devices on your network can access it
          "BIND_ADDRESS=0.0.0.0"
        ];

        # --- Sandbox Disables ---
        RestrictNamespaces = false;
        SystemCallFilter = [];
        PrivateTmp = false;
        ProtectSystem = "no";
        ProtectHome = "no";
        PrivateDevices = false;

        Restart = "always";
        ReadWritePaths = [vaultPath];
      };
    };

    # Automatically ensure the vault directory exists and is owned by zennotes
    systemd.tmpfiles.rules = [
      "d '${vaultPath}' 0755 zennotes zennotes - -"
    ];
  };
}
