{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # SDKs
    dotnet-sdk
    go
    jdk
  ];
}
