{
  ...
}:

let
  routerIp = "192.168.178.1";
  serverIp = "192.168.178.8";
  nasIp    = "192.168.178.20";
in

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "${serverIp}:8082";
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
              href = "http://${serverIp}:2283";
              icon = "immich.png";
              description = "Photos & Videos";
              siteMonitor = "http://${serverIp}:2283";
            };
          }
          {
            Jellyfin = {
              href = "http://${serverIp}:8096";
              icon = "jellyfin.png";
              description = "Movies & TV Shows";
              siteMonitor = "http://${serverIp}:8096";
            };
          }
        ];
      }
      {
        "Misc" = [
          {
            Linkding = {
              href = "http://${serverIp}:9090";
              icon = "linkding.png";
              description = "Bookmarks";
              siteMonitor = "http://${serverIp}:9090";
            };
          }
          {
            Radicale = {
              href = "http://${serverIp}:5232";
              icon = "radicale.png";
              description = "CalDAV and CardDAV Server";
              siteMonitor = "http://${serverIp}:5232";
            };
          }
        ];
      }
      {
        "Networking" = [
          {
            Router = {
              href = "http://${routerIp}";
              icon = "fritzbox.png";
              description = "FRITZ!Box 7510";
              siteMonitor = "http://${routerIp}";
            };
          }
        ];
      }
      {
        "Storage & Sync" = [
          {
            LambdaCore = {
              href = "http://${nasIp}:5000";
              icon = "synology-dsm.png";
              description = "Synology DS224+ NAS";
              siteMonitor = "http://${nasIp}:5000";
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
