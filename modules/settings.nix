{
  lib,
  settings,
  ...
}: {
  flake.nixosModules.settings = {
    settings = {
      admin = {
        name = "pim";
        device = "NixBTW";
        domain = "puber";
        pswd = "$6$VrOHvIFjn6HTuxUz$5gp2v0XFmRRx4eOv.X1EDiPXGyUD/OKYVByhUK609iuIZsxzW9l0fkbxmo9w1SNCzxbSD0DAj0gUeNQOSQwJX/";
        flakeDir = "/home/${settings.admin.name}/homeserver";
        gitChannel = "github:pimkoter/homeserver";
      };

      ip = {
        alpha = "192.168.178.2";
        beta = "192.168.178.3";
        gamma = "192.168.178.4";
        delta = "192.168.178.5";
        general = {
          gateway = "192.168.178.1";
          nameServer = settings.ip.alpha;
        };
      };
    };
    option.ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
      description = "Simple module to make opening up ports easier";
    };
  };
}
