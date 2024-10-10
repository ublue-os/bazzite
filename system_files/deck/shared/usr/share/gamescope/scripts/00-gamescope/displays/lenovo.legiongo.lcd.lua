gamescope.config.known_displays.lenovo_legiongo_lcd = {
    pretty_name = "Lenovo Legion Go LCD",
    dynamic_refresh_rates = {
        60,
        125, 126, 127, 128, 129,
        130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
        140, 141, 142, 143, 144
    },
    hdr = {
        -- Setup some fallbacks for undocking with HDR, meant
        -- for the internal panel. It does not support HDR.
        supported = false,
        force_enabled = false,
        eotf = gamescope.eotf.gamma22,
        max_content_light_level = 500,
        max_frame_average_luminance = 500,
        min_content_light_level = 0.5
    },
    -- Use the EDID colorimetry for now, but someone should check
    -- if the EDID colorimetry truly matches what the display is capable of.
    dynamic_modegen = function(base_mode, refresh)
        debug("Generating mode "..refresh.."Hz for Lenovo Legion Go LCD")
        local mode = base_mode

        -- These are only tuned for 1600x2560
        gamescope.modegen.set_resolution(mode, 1600, 2560)

        -- Horizontal timings: Hfront, Hsync, Hback
        gamescope.modegen.set_h_timings(mode, 60, 30, 130)
        -- Vertical timings: Vfront, Vsync, Vback
        gamescope.modegen.set_v_timings(mode, 30, 4, 96)

        mode.clock = gamescope.modegen.calc_max_clock(mode, refresh)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)

        return mode
    end,
    matches = function(display)
        -- There is only a single panel in use on Lenovo Legion Go devices.
        if display.vendor == "LEN" and display.model == "Go Display" and display.product == 0x0001 then
            debug("[lenovo_legiongo_lcd] Matched vendor: "..display.vendor.." model: "..display.model.." product: "..display.product)
            return 5000
        end
        return -1
    end
}
debug("Registered Lenovo Legion Go LCD as a known display")
--debug(inspect(gamescope.config.known_displays.lenovo_legiongo_lcd))
