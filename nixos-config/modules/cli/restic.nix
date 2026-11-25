{
  flake.modules.homeManager.restic = {
    home.file.".restic-exclude".source = ./restic/.restic-exclude;
  };
}
