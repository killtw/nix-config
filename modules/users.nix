{ username, hostname, pkgs, ... } @ args : {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = ["@admin" username];
}
