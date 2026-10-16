SoulTransfer = SoulTransfer or {}

hook.Add("PopulateToolMenu", "SoulTransfer_Menu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Soul Transfer", "SoulTransfer_Config", SoulTransfer.T("menu_title"), "", "", function(panel)
        panel:ClearControls()

        panel:Help(SoulTransfer.T("menu_desc"))
        panel:Help("")

        panel:Help("--- " .. SoulTransfer.T("cat_general") .. " (Admin) ---")
        panel:CheckBox(SoulTransfer.T("opt_enabled"), "soultransfer_enabled")
        panel:ControlHelp(SoulTransfer.T("opt_enabled_help"))

        panel:NumSlider(SoulTransfer.T("opt_range"), "soultransfer_range", 500, 5000, 0)
        panel:ControlHelp(SoulTransfer.T("opt_range_help"))

        panel:NumSlider(SoulTransfer.T("opt_time_limit"), "soultransfer_time_limit", 3, 20, 1)
        panel:ControlHelp(SoulTransfer.T("opt_time_limit_help"))

        panel:NumSlider(SoulTransfer.T("opt_transfer_duration"), "soultransfer_transfer_duration", 0.2, 1.5, 2)
        panel:ControlHelp(SoulTransfer.T("opt_transfer_duration_help"))

        panel:CheckBox(SoulTransfer.T("opt_slomo"), "soultransfer_slomo")
        panel:ControlHelp(SoulTransfer.T("opt_slomo_help"))

        panel:CheckBox(SoulTransfer.T("opt_preserve_hp"), "soultransfer_preserve_health")
        panel:ControlHelp(SoulTransfer.T("opt_preserve_hp_help"))

        panel:CheckBox(SoulTransfer.T("opt_allow_hostiles"), "soultransfer_allow_hostiles")
        panel:ControlHelp(SoulTransfer.T("opt_allow_hostiles_help"))

        panel:Help("")

        panel:Help("--- " .. SoulTransfer.T("cat_client") .. " ---")
        panel:CheckBox(SoulTransfer.T("opt_cl_hud"), "soultransfer_cl_hud")
        panel:ControlHelp(SoulTransfer.T("opt_cl_hud_help"))

        panel:CheckBox(SoulTransfer.T("opt_cl_blur"), "soultransfer_cl_blur")
        panel:ControlHelp(SoulTransfer.T("opt_cl_blur_help"))

        panel:CheckBox(SoulTransfer.T("opt_cl_strands"), "soultransfer_cl_strands")
        panel:ControlHelp(SoulTransfer.T("opt_cl_strands_help"))

        panel:CheckBox(SoulTransfer.T("opt_cl_strands_dark"), "soultransfer_cl_strands_dark")
        panel:ControlHelp(SoulTransfer.T("opt_cl_strands_dark_help"))

        panel:NumSlider(SoulTransfer.T("opt_cl_volume"), "soultransfer_cl_audio_volume", 0, 1, 2)
        panel:ControlHelp(SoulTransfer.T("opt_cl_volume_help"))

        panel:Help("")
        local resetBtn = panel:Button(SoulTransfer.T("btn_reset_visuals"))
        resetBtn.DoClick = function()
            RunConsoleCommand("soultransfer_cl_hud", "1")
            RunConsoleCommand("soultransfer_cl_blur", "1")
            RunConsoleCommand("soultransfer_cl_strands", "1")
            RunConsoleCommand("soultransfer_cl_strands_dark", "0")
            RunConsoleCommand("soultransfer_cl_audio_volume", "1.0")
        end
    end)
end)
