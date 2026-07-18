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

        # --- The Magic Trick ---
        BindPaths = ["/home/pim/notes:/var/empty/ZenNotesVault"];

        # Sandbox overrides
        RestrictNamespaces = false;
        SystemCallFilter = [];
        PrivateTmp = false;
        ProtectSystem = "no";
        ProtectHome = "no";
        PrivateDevices = false;

        Restart = "always";
      };
    };
  };
}
