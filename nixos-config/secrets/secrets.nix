let
  # user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI6jSq53F/3hEmSs+oq9L4TwOo1PrDMAgcA1uo1CCV/";
  ax    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMijZALYgRxmJpKAw7uzg+nVwcNfV8LihlasrlSHKsh ax@ax-bee";
  users = [ ax ];

  # system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  # system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  ax-bee  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKqqSF8D+ZnJ/C//ki/DbkhyVR3HNBW412Xn9oWFaGp root@ax-bee";
  ax-fuji = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG1C4QB1LocSzT6r84Sbzg+SHhDRAb7hz29LqTYV5j4 root@nixos";
  systems = [ ax-bee ax-fuji ];
in
{
  # "secret1.age".publicKeys = [ user1 system1 ];
  # "secret2.age".publicKeys = users ++ systems;
  # "armored-secret.age" = {
  #   publicKeys = [ user1 ];
  #   armor = true;
  # };

  # corresponding .age file has to exist before rebuild:
  # 1) cd /home/ax/syscfg/nixos-config/secrets
  # 2) makepasswd                        # copy the hash
  # 3) agenix -e testuser-password.age   # paste the hash, save+quit
  # if not installed: nix run github:ryantm/agenix -- --help
 "testuser-password.age".publicKeys = [ ax ax-bee ];
 "searx-secret-key.age".publicKeys  = [ ax ax-fuji ];
 "ax-bee-restic-b2.age".publicKeys  = [ ax ax-bee ];
 "ax-bee-restic-mega.age".publicKeys = [ ax ax-bee ];
 "ax-bee-networkmanager-muc.age".publicKeys = [ ax ax-bee ];
}

