{ cfg, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_18;

  boot.kernelModules = [ "amd-pstate" ];
  boot.kernelParams =
    [ "initcall_blacklist=acpi_cpufreq_init" "amd_pstate.shared_mem=1" ];
}
