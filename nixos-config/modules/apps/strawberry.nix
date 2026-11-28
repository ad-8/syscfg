{
  flake.modules.homeManager.strawberry =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # TODO: remove the override once nixpkgs ships strawberry >= 1.2.29 (old Last.fm API key suspended)
        (strawberry.overrideAttrs (old: rec {
          version = "1.2.31";
          src = fetchFromGitHub {
            owner = "strawberrymusicplayer";
            repo = "strawberry";
            rev = version;
            hash = "sha256-U9qRaadhhHmzWBPS4QhofKAyVkZ+o7+emfNuRZRKWA0=";
          };
          buildInputs = old.buildInputs ++ [
            openssl
            libuchardet
            libsecret
          ];
          doCheck = false;
        }))
      ];
    };
}
