{lib, ...}:
let
  options.dnsIp = lib.mkOption {
    type = lib.types.str;
  };
in
{
  flake.nixosModules.settings = {settings, ...}: {
    settings = {
      dnsIp = 
    };

    admin = {
      name = "pim";
      domain = "puber";
      pswd = "$6$VrOHvIFjn6HTuxUz$5gp2v0XFmRRx4eOv.X1EDiPXGyUD/OKYVByhUK609iuIZsxzW9l0fkbxmo9w1SNCzxbSD0DAj0gUeNQOSQwJX/";
      flakeDir = "/home/${settings.admin.name}/homeserver";
      gitChannel = "github:pimkoter/homeserver";
    };
  };
}
