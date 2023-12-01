bluez_monitor.properties = {
  -- we only want these audio profiles:
  -- 0000110a-0000-1000-8000-00805f9b34fb Audio Source
  -- 0000110b-0000-1000-8000-00805f9b34fb Audio Sink
  -- 0000110d-0000-1000-8000-00805f9b34fb Advanced Audio Distribution
  ["bluez5.roles"] = "[ a2dp_sink a2dp_source ]",

  -- And only this one headset related profile:
  -- 00001112-0000-1000-8000-00805f9b34fb Headset
  -- disabled: 00001108-0000-1000-8000-00805f9b34fb hsp_hs
  -- disabled: 0000111e-0000-1000-8000-00805f9b34fb hfp_hs
  -- disabled: 0000111f-0000-1000-8000-00805f9b34fb hfp_ag
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  -- NOTE: check hfphsp-backend below as that also affects hs/hf profiles
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ["bluez5.headset-roles"] = "[ hsp_ag ]",

  -- HFP/HSP backend (default: native).
  -- Available values: any, none, hsphfpd, ofono, native
  -- setting this to "none" disables all headset roles
  ["bluez5.hfphsp-backend"] = "none",

  -- Disable dummy AVRCP player
  ["bluez5.dummy-avrcp-player"] = false
}
