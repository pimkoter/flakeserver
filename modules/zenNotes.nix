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

        # --- FIX: Set HOME to the parent of your vault ---
        # If your vault is /home/pim/notes, set HOME to /home/pim/notes
        # The app will then look for /home/pim/notes/ZenNotesVault
        Environment = [
          "PORT=${toString port}"
          "HOME=${vaultPath}"
          "BIND_ADDRESS=0.0.0.0"
        ];

        # Sandbox overrides
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

    systemd.tmpfiles.rules = [
      # Ensure the directory exists
      "d '${vaultPath}' 0755 zennotes zennotes - -"
    ];
  };
}
