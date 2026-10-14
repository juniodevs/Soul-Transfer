SoulTransfer = SoulTransfer or {}
SoulTransfer.ScreenFX = SoulTransfer.ScreenFX or {}

local arrivalFlash = 0

function SoulTransfer.ScreenFX.TriggerArrivalFlash()
    arrivalFlash = 1.0
end

hook.Add("RenderScreenspaceEffects", "SoulTransfer_PostProcessing", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if arrivalFlash > 0 then
        local flashColor = {
            ["$pp_colour_addr"] = 0.35 * arrivalFlash,
            ["$pp_colour_addg"] = 0.1 * arrivalFlash,
            ["$pp_colour_addb"] = 0.1 * arrivalFlash,
            ["$pp_colour_brightness"] = 0.45 * arrivalFlash,
            ["$pp_colour_contrast"] = 1.0 + (0.4 * arrivalFlash),
            ["$pp_colour_colour"] = 1.0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(flashColor)
        arrivalFlash = math.Approach(arrivalFlash, 0, FrameTime() * 3.5)
    end

    if not isSpectral and not isTransferring then return end

    local cv_blur = GetConVar("soultransfer_cl_blur")
    local allowBlur = cv_blur and cv_blur:GetBool()

    if isTransferring then
        local diveColor = {
            ["$pp_colour_addr"] = 0.25,
            ["$pp_colour_addg"] = 0.0,
            ["$pp_colour_addb"] = 0.0,
            ["$pp_colour_brightness"] = -0.45,
            ["$pp_colour_contrast"] = 3.2,
            ["$pp_colour_colour"] = 0.2,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(diveColor)

        if allowBlur then
            DrawMotionBlur(0.06, 0.94, 0.04)
        end
        DrawSharpen(3.0, 1.2)
        return
    end

    if isSpectral then
        local voidColor = {
            ["$pp_colour_addr"] = 0.0,
            ["$pp_colour_addg"] = 0.0,
            ["$pp_colour_addb"] = 0.0,
            ["$pp_colour_brightness"] = -0.78,
            ["$pp_colour_contrast"] = 3.6,
            ["$pp_colour_colour"] = 0.0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(voidColor)

        if allowBlur then
            DrawMotionBlur(0.25, 0.65, 0.02)
        end
    end
end)
