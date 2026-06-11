{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.users = {
    users.users = {
      pim = {
        isNormalUser = true;
        hashedPassword = "$6$VrOHvIFjn6HTuxUz$5gp2v0XFmRRx4eOv.X1EDiPXGyUD/OKYVByhUK609iuIZsxzW9l0fkbxmo9w1SNCzxbSD0DAj0gUeNQOSQwJX/";
        extraGroups = ["wheel"];
      };
    };
  };
}
