# Custom library functions
{ inputs, snowfall-inputs, lib, ... }:

let
  # Import Home Manager specific functions
  homeLib = import ./home.nix { inherit lib; };
in

# Merge all library functions
homeLib // {
  # Generic utility function to create options with custom types
  mkOpt = type: default: description:
    lib.mkOption {
      inherit type default description;
    };

  # Utility function to create boolean options with default values
  mkBoolOpt = default: description:
    lib.mkOption {
      type = lib.types.bool;
      inherit default description;
    };

  # Utility function to create string options with default values
  mkStrOpt = default: description:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  # Utility function to create nullable string options
  mkStrOptNull = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      inherit description;
    };

  # Utility function to create integer options with default values
  mkIntOpt = default: description:
    lib.mkOption {
      type = lib.types.int;
      inherit default description;
    };

  # Utility function to create nullable integer options
  mkIntOptNull = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      inherit description;
    };

  # Utility function to create float options with default values
  mkFloatOpt = default: description:
    lib.mkOption {
      type = lib.types.float;
      inherit default description;
    };

  # Utility function to create list options with default values
  mkListOpt = elementType: default: description:
    lib.mkOption {
      type = lib.types.listOf elementType;
      inherit default description;
    };

  # Utility function to create attribute set options with default values
  mkAttrsOpt = default: description:
    lib.mkOption {
      type = lib.types.attrs;
      inherit default description;
    };

  # Utility function to create package options
  mkPackageOpt = default: description:
    lib.mkOption {
      type = lib.types.package;
      inherit default description;
    };

  # Utility function to create nullable package options
  mkPackageOptNull = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      inherit description;
    };

  # Utility function to create enum options
  mkEnumOpt = values: default: description:
    lib.mkOption {
      type = lib.types.enum values;
      inherit default description;
    };

  # Utility function to enable a module
  enabled = {
    enable = true;
  };

  # Utility function to disable a module
  disabled = {
    enable = false;
  };

  # Package management helpers
  mkPackageWithFallback = cfg: defaultPkg:
    if cfg.package != null then cfg.package else defaultPkg;

  # Conditional package inclusion
  mkConditionalPackages = condition: packages:
    if condition then packages else [];

}
