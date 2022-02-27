{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # SDKs
    dotnet-sdk
    go
    jdk

    # Editors
    jetbrains.clion
    jetbrains.goland
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rider
    vscode

    # Misc tools
    ghidra
    postman
    sqlitebrowser
  ];
}
