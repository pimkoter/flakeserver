{
  flake.nixosModules.immich =
    { config, lib, ... }:
    let
      baseDir = "${config.disks.mntPoint}/foto";
      immichDataDir = "${baseDir}/immich-data";

      # Immich's required integrity subdirectories
      subDirs = [
        "thumbs"
        "upload"
        "backups"
        "library"
        "profile"
        "encoded-video"
      ];

      # Shell script to build structure & hidden marker files before service starts
      initScript = ''
        mkdir -p ${immichDataDir} ${baseDir}/library
        ${builtins.concatStringsSep "\n" (
          map (dir: ''
            mkdir -p ${immichDataDir}/${dir}
            touch ${immichDataDir}/${dir}/.immich
          '') subDirs
        )}
        chown -R immich:immich ${immichDataDir} ${baseDir}/library
        chmod -R 750 ${immichDataDir}
        chmod -R 755 ${baseDir}/library
      '';
    in
    {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        openFirewall = true;
        mediaLocation = immichDataDir;
      };

      # Automatically run the initial folder/file setup script inside systemd before Immich fires up
      systemd.services.immich-server = {
        preStart = lib.mkAfter initScript;
        serviceConfig.ReadWritePaths = [ baseDir ];
      };

      systemd.services.immich-machine-learning.serviceConfig.ReadWritePaths = [ baseDir ];
    };
}
