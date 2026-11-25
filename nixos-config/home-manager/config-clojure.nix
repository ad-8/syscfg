{
  config,
  lib,
  ...
}:

{
  options = {
    configClojure.enable = lib.mkEnableOption "Enable clojure CLI config";
  };

  config = lib.mkIf config.configClojure.enable {
    home.file.".clojure/deps.edn".source = ./files/clojure/deps.edn;
  };
}
