let
  ax    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMijZALYgRxmJpKAw7uzg+nVwcNfV8LihlasrlSHKsh ax@ax-bee";
  users = [ ax ];

  ax-bee  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKqqSF8D+ZnJ/C//ki/DbkhyVR3HNBW412Xn9oWFaGp root@ax-bee";
  ax-fuji = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG1C4QB1LocSzT6r84Sbzg+SHhDRAb7hz29LqTYV5j4 root@nixos";
  systems = [ ax-bee ax-fuji ];
in
{
 "searx-secret-key.age".publicKeys  = [ ax ax-fuji ];
 "ax-fuji-restic-immich.age".publicKeys = [ ax ax-fuji ];
 "ax-bee-restic-b2.age".publicKeys  = [ ax ax-bee ax-fuji ];
 "ax-bee-restic-mega.age".publicKeys = [ ax ax-bee ];
 "ax-bee-networkmanager-muc.age".publicKeys = [ ax ax-bee ];
}

