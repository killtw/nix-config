# Custom library functions
{ inputs, snowfall-inputs, lib, ... }:

{
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

  # Utility function to enable a module
  enabled = {
    enable = true;
  };
}
