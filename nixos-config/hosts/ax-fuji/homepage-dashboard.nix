{
  ...
}:

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "192.168.178.8:8082";
    settings = {
      statusStyle = "dot";
    };
    widgets = [
      {
        logo = {
          icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Half-Life_lambda_logo.svg/250px-Half-Life_lambda_logo.svg.png";
        };
      }
      {
        greeting = {
          text_size = "xl";
          text = "LambdaLab";
        };
      }
      {
        datetime = {
          locale = "de-DE";
          text_size = "xl";
          format = {
            hourCycle = "h23";
            dateStyle = "full";
            timeStyle = "medium";
          };
        };
      }
      {
        resources = {
          label = "system resources";
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
      {
        resources = {
          label = "uptime";
          uptime = true;
        };
      }
    ];
    services = [
      {
        "Media" = [
          {
            Immich = {
              href = "http://192.168.178.8:2283";
              icon = "immich.png";
              description = "Photos & Videos";
              siteMonitor = "http://192.168.178.8:2283";
            };
          }
          {
            Jellyfin = {
              href = "http://192.168.178.8:8096";
              icon = "jellyfin.png";
              description = "Movies & TV Shows";
              siteMonitor = "http://192.168.178.8:8096";
            };
          }
        ];
      }
      {
        "Misc" = [
          {
            Linkding = {
              href = "http://192.168.178.8:9090";
              icon = "linkding.png";
              description = "Bookmarks";
              siteMonitor = "http://192.168.178.8:9090";
            };
          }
          {
            Radicale = {
              href = "http://192.168.178.8:5232";
              icon = "radicale.png";
              description = "CalDAV and CardDAV Server";
              siteMonitor = "http://192.168.178.8:5232";
            };
          }
        ];
      }
      {
        "Networking" = [
          {
            Router = {
              href = "http://192.168.178.1";
              icon = "fritzbox.png";
              description = "FRITZ!Box 7510";
              siteMonitor = "http://192.168.178.1";
            };
          }
        ];
      }
      {
        "Storage & Sync" = [
          {
            LambdaCore = {
              href = "http://192.168.178.20:5000";
              icon = "synology-dsm.png";
              description = "Synology DS224+ NAS";
              siteMonitor = "http://192.168.178.20:5000";
            };
          }
          {
            Syncthing = {
              # href = "http://127.0.0.1:8384"; # not sure how to set this up with syncthing running on the client as well
              icon = "syncthing.png";
              description = "File Sync";
              siteMonitor = "http://127.0.0.1:8384"; # but this works
            };
          }
        ];
      }
    ];

  };
}
