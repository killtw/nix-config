{ machineConfig, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit machineConfig; };
    users.${machineConfig.username} = import ../home;
  };
}
