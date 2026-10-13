SoulTransfer = SoulTransfer or {}

surface.CreateFont("SoulTransfer_Title", {
    font = "Roboto",
    size = 22,
    weight = 700,
    antialias = true
})

surface.CreateFont("SoulTransfer_Small", {
    font = "Roboto",
    size = 15,
    weight = 500,
    antialias = true
})

hook.Add("HUDPaint", "SoulTransfer_DrawSpectralHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if not isSpectral and not isTransferring then return end

    local cv_hud = GetConVar("soultransfer_cl_hud")
    if cv_hud and not cv_hud:GetBool() then return end

    local scrW, scrH = ScrW(), ScrH()
    local midX, midY = scrW / 2, scrH / 2

    surface.SetDrawColor(255, 60, 60, 200)
    surface.DrawCircle(midX, midY, 6, 255, 60, 60, 220)
    surface.DrawCircle(midX, midY, 20, 255, 40, 40, 110)

    if isTransferring then
        draw.SimpleText(SoulTransfer.T("hud_transferring"), "SoulTransfer_Title", midX, midY + 45, Color(255, 100, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local startTime = ply:GetNWFloat("ST_SoulStartTime", CurTime())
    local timeLimit = ply:GetNWFloat("ST_SoulTimeLimit", 8)
    local elapsed = CurTime() - startTime
    local remaining = math.max(0, timeLimit - elapsed)
    local progress = math.Clamp(remaining / timeLimit, 0, 1)

    local barW, barH = 320, 8
    local barX, barY = midX - (barW / 2), scrH - 120

    draw.RoundedBox(4, barX - 2, barY - 2, barW + 4, barH + 4, Color(10, 5, 5, 230))
    local barColor = remaining < 2.5 and Color(255, 40, 40, 255) or Color(220, 45, 45, 230)
    draw.RoundedBox(4, barX, barY, barW * progress, barH, barColor)

    draw.SimpleText(SoulTransfer.T("hud_time_left", remaining), "SoulTransfer_Small", midX, barY - 14, Color(255, 180, 180, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local target = SoulTransfer.Targeting.CurrentTarget
    if IsValid(target) then
        local targetName = target:GetClass()
        local targetHp = math.max(0, target:Health())
        local maxHp = math.max(1, target:GetMaxHealth())
        local hpFrac = math.Clamp(targetHp / maxHp, 0, 1)

        local cardW, cardH = 260, 52
        local cardX, cardY = midX - (cardW / 2), midY + 36

        draw.RoundedBox(6, cardX, cardY, cardW, cardH, Color(15, 8, 8, 230))
        draw.SimpleText(SoulTransfer.T("hud_target_info", targetName, targetHp), "SoulTransfer_Small", midX, cardY + 16, Color(255, 220, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(3, cardX + 20, cardY + 32, cardW - 40, 6, Color(40, 15, 15, 200))
        draw.RoundedBox(3, cardX + 20, cardY + 32, (cardW - 40) * hpFrac, 6, Color(255, 50, 50, 240))

        draw.SimpleText(SoulTransfer.T("hud_choose_target"), "SoulTransfer_Small", midX, barY + 24, Color(255, 90, 90, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(SoulTransfer.T("hud_choose_target"), "SoulTransfer_Small", midX, barY + 24, Color(200, 120, 120, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
