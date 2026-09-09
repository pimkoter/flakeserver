#!/usr/bin/env bash
sudo nixos-rebuild switch --flake .#omega \
  --target-host root@192.168.178.10 \
  --build-host localhost
