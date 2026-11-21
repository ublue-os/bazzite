-- Acer Nitro Blaze 7 (GN771) LCD: BOE product 3363 (no model string), 1920x1080.
-- EDID: DTD 1 is 144 Hz at 338.76 MHz, H 1920+48+32+80, V 1080+41+2+8; range limits 48-144 Hz with a
-- fixed pixel clock. Each rate keeps that clock and stretches the vertical front porch:
-- vfp = round(338760000 / (2080 * Hz)) - 1090, within 0.06 Hz of the target.
local blaze7_lcd_refresh_rates = {
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
    58, 59, 60, 61, 62, 63, 64, 65, 66, 67,
    68, 69, 70, 71, 72, 73, 74, 75, 76, 77,
    78, 79, 80, 81, 82, 83, 84, 85, 86, 87,
    88, 89, 90, 91, 92, 93, 94, 95, 96, 97,
    98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
    108, 109, 110, 111, 112, 113, 114, 115, 116, 117,
    118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
    128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
    138, 139, 140, 141, 142, 143, 144
}

gamescope.config.known_displays.acer_nitroblaze7_lcd = {
    pretty_name = "Acer Nitro Blaze 7 LCD",
    hdr = {
        supported = false,
        force_enabled = false,
        eotf = gamescope.eotf.gamma22,
        max_content_light_level = 500,
        max_frame_average_luminance = 500,
        min_content_light_level = 0.5
    },
    dynamic_refresh_rates = blaze7_lcd_refresh_rates,
    dynamic_modegen = function(base_mode, refresh)
        debug("Generating mode "..refresh.."Hz for Acer Nitro Blaze 7 LCD with fixed pixel clock")
        local vfps = {
            2303, 2234, 2167, 2103, 2042, 1983, 1926, 1871, 1818, 1767,
            1718, 1670, 1624, 1580, 1537, 1495, 1455, 1416, 1378, 1341,
            1305, 1270, 1237, 1204, 1172, 1141, 1111, 1082, 1053, 1025,
             998,  972,  946,  921,  896,  872,  849,  826,  804,  782,
             761,  740,  720,  700,  680,  661,  643,  624,  607,  589,
             572,  555,  539,  523,  507,  491,  476,  461,  446,  432,
             418,  404,  391,  377,  364,  351,  339,  326,  314,  302,
             290,  279,  267,  256,  245,  234,  223,  213,  203,  192,
             182,  173,  163,  153,  144,  135,  125,  116,  108,   99,
              90,   82,   73,   65,   57,   49,   41
        }
        local vfp = vfps[zero_index(refresh - 48)]
        if vfp == nil then
            warn("Couldn't do refresh "..refresh.." on Acer Nitro Blaze 7 LCD")
            return base_mode
        end
        -- Start from the native 144 Hz timing whichever EDID mode gamescope passes in
        -- (the 120 Hz mode stretches the back porch and the 60 Hz one uses another clock).
        local mode = base_mode
        gamescope.modegen.set_resolution(mode, 1920, 1080)
        gamescope.modegen.set_h_timings(mode, 48, 32, 80)
        gamescope.modegen.set_v_timings(mode, 41, 2, 8)
        mode.clock = 338760
        gamescope.modegen.adjust_front_porch(mode, vfp)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)
        return mode
    end,
    matches = function(display)
        if display.vendor == "BOE" and display.product == 3363 then
            debug("[acer_nitroblaze7_lcd] Matched vendor: "..display.vendor.." product: "..display.product)
            return 5000
        end
        return -1
    end
}
debug("Registered Acer Nitro Blaze 7 LCD as a known display")
