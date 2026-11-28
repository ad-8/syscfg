{
  flake.modules.homeManager.clojure =
    { pkgs, ... }:
    {
      home.file.".clojure/deps.edn".source = ./deps.edn;

      home.packages = with pkgs; [
        clojure
        clojure-lsp
        leiningen
      ];
    };
}
