# Suites module collection
{ lib, config, namespace, ... }:

with lib;
with lib.${namespace};

{
  # This module serves as a container for all suite modules
  # Individual suites are defined in their respective subdirectories

  options.${namespace}.suites = {
    # Suite options are defined in individual suite modules
  };

  config = {
    # Suite configurations are handled by individual suite modules
  };
}
