sudo nix --extra-experimental-features "nix-command flakes" \
         run 'github:nix-community/disko/latest#disko-install' --\
         --flake .#${PUT NAME HERE}\
         --disk main /dev/sda
