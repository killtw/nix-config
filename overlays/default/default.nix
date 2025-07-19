# Default overlay for custom packages and modifications
{ inputs, ... }:

final: prev: {
  # Add custom packages or modify existing ones here
  # Example:
  # my-custom-package = final.callPackage ./my-custom-package { };
}
