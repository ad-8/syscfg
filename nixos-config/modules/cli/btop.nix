let
  settings = {
    color_theme = "active";
    save_config_on_exit = false;
  };
in
{
  flake.modules.homeManager.btop = {
    programs.btop = {
      enable = true;
      inherit settings;
    };
  };

  flake.modules.nixos.btop =
    { lib, pkgs, ... }:
    let
      btopConf = pkgs.writeText "btop.conf" (
        lib.generators.toKeyValue {
          mkKeyValue = lib.generators.mkKeyValueDefault {
            mkValueString =
              v: if builtins.isString v then "\"${v}\"" else lib.generators.mkValueStringDefault { } v;
          } " = ";
        } settings
      );
    in
    {
      environment.systemPackages = [
        pkgs.btop
        (lib.hiPrio (
          pkgs.writeShellScriptBin "btop" ''
            exec ${pkgs.btop}/bin/btop --config ${btopConf} "$@"
          ''
        ))
      ];
    };
}
