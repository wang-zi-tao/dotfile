all:
	git add . && sudo nixos-rebuild switch --flake .
