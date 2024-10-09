local lenovo_legiongo_lcd_colorimetry = {
    r = { x = 0.6250, y = 0.3398 },
    g = { x = 0.2802, y = 0.5947 },
    b = { x = 0.1552, y = 0.0703 },
    w = { x = 0.2832, y = 0.2978 }
}

gamescope.config.known_displays.lenovo_legiongo_lcd = {
    pretty_name = "Lenovo Legion Go LCD",
    dynamic_refresh_rates = {
        60, 125, 126, 127, 128, 129, 130, 131, 132, 133,
        134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
        144
    },
    hdr = {
        supported = false,
        force_enabled = false,
        eotf = gamescope.eotf.gamma22,
        max_content_light_level = 500,
        max_frame_average_luminance = 500,
        min_content_light_level = 0.5
    },
    colorimetry = lenovo_legiongo_lcd_colorimetry,
    dynamic_modegen = function(base_mode, refresh)
        debug("Generating mode "..refresh.."Hz for Lenovo Legion Go LCD")
        local mode = base_mode

        -- Set resolution to 1600x2560
        gamescope.modegen.set_resolution(mode, 1600, 2560)

        -- Horizontal timings: Hfront, Hsync, Hback
        gamescope.modegen.set_h_timings(mode, 60, 30, 130)
        -- Vertical timings: Vfront, Vsync, Vback
        gamescope.modegen.set_v_timings(mode, 30, 4, 96)

        -- Calculate pixel clock and refresh rate
        mode.clock = gamescope.modegen.calc_max_clock(mode, refresh)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)

        return mode
    end,
    matches = function(display)
        if display.vendor == "LEN" and display.model == "Go Display" then
            debug("[lenovo_legiongo_lcd] Matched vendor: "..display.vendor.." model: "..display.model)
            return 5000
        end
        return -1
    end
}
debug("Registered Lenovo Legion Go LCD as a known display")
