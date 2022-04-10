{ lib, domain, entryPoint, network, ... }:

let
  makeTraefikLabels = { name, entryPoint, rule, port ? null, service ? false }:
    [
      "--label"
      "traefik.enable=true"
      "--label"
      "traefik.http.routers.${name}.entryPoints=${entryPoint}"
      "--label"
      "traefik.http.routers.${name}.rule=${rule}"
    ] ++ lib.optionals (port != null) [
      "--label"
      "traefik.http.services.${name}.loadbalancer.server.port=${toString port}"
    ] ++ lib.optionals service [
      "--label"
      "traefik.http.routers.${name}.service=${name}"
    ];

  traefikLabels = { name, hostname ? name, port ? null, service ? false }:
    makeTraefikLabels {
      inherit name entryPoint port service;
      rule = "Host(`${hostname}.${domain}`)";
    };
  traefikLabelsSimple = name:
    makeTraefikLabels {
      inherit name entryPoint;
      rule = "Host(`${name}.${domain}`)";
    };
in {
  inherit traefikLabels traefikLabelsSimple;

  containerLabels = { name, hostname ? name, port ? null, service ? false }:
    [ "--network=${network}" ]
    ++ traefikLabels { inherit name hostname port service; };

  containerLabelsSimple = name:
    [ "--network=${network}" ] ++ traefikLabelsSimple name;
}
