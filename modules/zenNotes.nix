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
        Restart = "always";
        User = "zennotes";
        Group = "zennotes";
        Environment = [
          "PORT=${toString port}"
          "VAULT_PATH=${vaultPath}"
        ];
        ReadWritePaths = [vaultPath];
      };
    };
  };
}
