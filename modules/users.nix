{ machineConfig, ... } @ args : {
  networking.hostName = machineConfig.hostname;
  networking.computerName = machineConfig.hostname;
  system.defaults.smb.NetBIOSName = machineConfig.hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${machineConfig.username}" = {
    home = "/Users/${machineConfig.username}";
    description = machineConfig.username;
  };

  nix.settings.trusted-users = ["@admin" machineConfig.username];
}
