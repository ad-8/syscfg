{
  config,
  lib,
  ...
}:

{
  options = {
    configAudio.enable = lib.mkEnableOption "Enable sound with PipeWire";
  };

  config = lib.mkIf config.configAudio.enable {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
