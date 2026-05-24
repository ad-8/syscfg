{
  config,
  lib,
  pkgs,
  ...
}:

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/firefox.nix
# https://mozilla.github.io/policy-templates/

{
  options = {
    configFirefox.enable = lib.mkEnableOption "Enable Firefox with locked-down defaults";
  };

  config = lib.mkIf config.configFirefox.enable {

    programs.firefox = {
      enable = true;

      policies = {
        # Telemetry / messaging / sponsored content
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableFeedbackCommands = true;
        UserMessaging = {
          ExtensionRecommendations = false;
          FeatureRecommendations = false; # the "you can pin tabs!" popups
          UrlbarInterventions = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          FirefoxLabs = false; # Firefox 130+
          Locked = true;
        };
        FirefoxSuggest = {
          # sponsored URL bar suggestions
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };

        # First-run cleanup
        OverrideFirstRunPage = ""; # no welcome/marketing page
        DisableProfileImport = true; # no "import from Chrome" prompt
        DontCheckDefaultBrowser = true; # no "make Firefox default?" nag

        # Startup + new tab + homepage
        Homepage = {
          URL = "about:blank";
          StartPage = "previous-session"; # restore tabs on launch
        };
        NewTabPage = false; # blank new tab instead of Firefox Home

        # Search
        SearchEngines = {
          Default = "DuckDuckGo";
          # optional: Remove = [ "Amazon.com" "Bing" "eBay" ];
        };

        # Tracking protection — Strict (Firefox 142+).
        # Category="strict" overrides the per-feature toggles and follows whatever
        # Mozilla bundles into Strict (blocks tracking content + suspected
        # fingerprinters in all windows, email tracking, etc.) including future
        # additions. BaselineExceptions defaults on, mitigating major site breakage.
        # Locked=false leaves the URL-bar shield per-site escape hatch available
        # for when a site breaks under Strict.
        EnableTrackingProtection = {
          Value = true;
          Locked = false;
          Category = "strict";
        };

        # Permissions — defaults that stop sites from asking
        Permissions = {
          Camera.BlockNewRequests = true;
          Microphone.BlockNewRequests = true;
          Location.BlockNewRequests = true;
          Notifications.BlockNewRequests = true; # never ask "allow notifications?"
          Autoplay.Default = "block-audio-video"; # silent tabs by default
        };

        # AI controls (Firefox 149.0.2+) — block everything by default, allow page
        # translation explicitly (local ML model for foreign-language pages).
        # Translations is left unlocked so it can be toggled in Settings.
        AIControls = {
          Default = {
            Value = "blocked";
            Locked = true;
          };
          Translations = {
            Value = "available";
          };
        };

        # System integration
        HardwareAcceleration = true; # usually default, set explicitly
        # NOTE: DisableAppUpdate is set automatically by the NixOS firefox module.

        # Extensions — declarative install via policy
        # IDs: about:support → Extensions section, or after manual install.
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            private_browsing = true; # Firefox 136+ / ESR 128.8+
          };
          "{73a6fe31-595d-460b-a920-fcc0f8843232}" = {
            # NoScript
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/noscript/latest.xpi";
            private_browsing = true;
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            private_browsing = true;
          };
          "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
            # Old Reddit Redirect
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
            private_browsing = true;
          };
        };
      };

      # Allow-listed prefs go in `preferences` (becomes the Preferences policy).
      preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome.css
        "extensions.htmlaboutaddons.recommendations.enabled" = false; # no recommendation cards in about:addons
      };

      # Non-allow-listed prefs (e.g. sidebar.*) go via autoConfig / mozilla.cfg.
      autoConfig = ''
        // mozilla.cfg: Firefox skips the first line, keep this comment here.
        defaultPref("sidebar.revamp", true);
        defaultPref("sidebar.verticalTabs", true);
      '';
    };
  };
}
