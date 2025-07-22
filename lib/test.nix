# Test file for lib functions
{ lib ? import <nixpkgs/lib> }:

let
  customLib = import ./default.nix { 
    inherit lib; 
    inputs = {}; 
    snowfall-inputs = {}; 
  };
in

with customLib;

{
  # Test basic option creation functions
  testBoolOpt = mkBoolOpt true "Test boolean option";
  testStrOpt = mkStrOpt "default" "Test string option";
  testIntOpt = mkIntOpt 42 "Test integer option";
  testFloatOpt = mkFloatOpt 3.14 "Test float option";
  
  # Test nullable options
  testStrOptNull = mkStrOptNull "Test nullable string option";
  testPackageOptNull = mkPackageOptNull "Test nullable package option";
  
  # Test list and attrs options
  testListOpt = mkListOpt lib.types.str [] "Test list option";
  testAttrsOpt = mkAttrsOpt {} "Test attrs option";
  
  # Test enum option
  testEnumOpt = mkEnumOpt ["option1" "option2" "option3"] "option1" "Test enum option";
  
  # Test Home Manager specific functions
  testTerminalOptions = mkTerminalOptions "TestApp";
  testDevelopmentToolOptions = mkDevelopmentToolOptions "TestTool";
  testCloudToolOptions = mkCloudToolOptions "TestCloud";
  testSystemToolOptions = mkSystemToolOptions "TestSystem";
  
  # Test suite options
  testSuiteOptions = mkSuiteOptions "test" ["module1" "module2" "module3"];
  
  # Test utility functions
  testConditionalPackages = mkConditionalPackages true ["package1" "package2"];
  testConditionalPackagesFalse = mkConditionalPackages false ["package1" "package2"];
  
  # Test assertions
  testAssertions = mkAppAssertions "TestApp" { enable = true; package = null; };
  
  # Test enabled/disabled utilities
  testEnabled = enabled;
  testDisabled = disabled;
}
