# Colima container runtime module with namespace support
{ lib, pkgs, config, namespace, ... }:

with lib;
with lib.${namespace};

let
  cfg = config.${namespace}.programs.cloud.colima;
in
{
  options.${namespace}.programs.cloud.colima = mkCloudToolOptions "Colima" // {
    # Colima-specific options
    enableDocker = mkBoolOpt true "Enable Docker CLI";
    enableDockerCompose = mkBoolOpt true "Enable Docker Compose";

    cpu = mkIntOpt 2 "Number of CPUs";
    memory = mkIntOpt 4 "Memory in GB";
    disk = mkIntOpt 60 "Disk size in GB";

    runtime = mkEnumOpt [ "docker" "containerd" ] "docker" "Container runtime";

    autoStart = mkBoolOpt false "Auto start Colima on login";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases for Colima";
    };
  };

  config = mkIf cfg.enable {
    # Assertions using lib helper
    assertions = mkAppAssertions "Colima" cfg ++ [
      {
        assertion = cfg.cpu > 0;
        message = "Colima CPU count must be positive";
      }
      {
        assertion = cfg.memory > 0;
        message = "Colima memory must be positive";
      }
      {
        assertion = cfg.disk > 0;
        message = "Colima disk size must be positive";
      }
    ];

    home.packages = [
      (mkPackageWithFallback cfg pkgs.colima)
    ] ++ mkConditionalPackages cfg.enableDocker [
      pkgs.docker
    ] ++ mkConditionalPackages cfg.enableDockerCompose [
      pkgs.docker-compose
    ];
  };
}
