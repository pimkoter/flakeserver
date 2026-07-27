{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.pkgs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ripgrep
      neovim
      git
      lazygit
      lazydocker
    ];
  };
}
