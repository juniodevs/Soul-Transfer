SoulTransfer = SoulTransfer or {}
SoulTransfer.Targeting = SoulTransfer.Targeting or {}

SoulTransfer.Targeting.CurrentTarget = nil
local nextTargetCheck = 0

local function UpdateSelectedHost()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if not isSpectral or isTransferring then
        SoulTransfer.Targeting.CurrentTarget = nil
        return
    end

    if CurTime() < nextTargetCheck then return end
    nextTargetCheck = CurTime() + 0.04

    local deathPos = ply:GetNWVector("ST_DeathPos", ply:GetPos())
    local range = GetConVar("soultransfer_range"):GetFloat()

    local eyePos = EyePos()
    local aimVector = ply:EyeAngles():Forward()

    local bestTarget = nil
    local bestDot = 0.82

    for _, ent in ipairs(ents.FindInSphere(deathPos, range)) do
        if not IsValid(ent) or not (ent:IsNPC() or ent:IsNextBot()) or ent:Health() <= 0 then continue end

        local targetPos = ent:WorldSpaceCenter()
        local dirToTarget = (targetPos - eyePos):GetNormalized()
        local dot = aimVector:Dot(dirToTarget)

        if dot > bestDot then
            bestDot = dot
            bestTarget = ent
        end
    end

    SoulTransfer.Targeting.CurrentTarget = bestTarget
end

hook.Add("Think", "SoulTransfer_UpdateTargeting", function()
    UpdateSelectedHost()
end)

hook.Add("PreDrawHalos", "SoulTransfer_TargetHalo", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)
    if not isSpectral and not isTransferring then return end

    local deathPos = ply:GetNWVector("ST_DeathPos", ply:GetPos())
    local range = GetConVar("soultransfer_range"):GetFloat()
    local selectedTarget = SoulTransfer.Targeting.CurrentTarget

    local otherHosts = {}
    for _, ent in ipairs(ents.FindInSphere(deathPos, range)) do
        if not IsValid(ent) or not (ent:IsNPC() or ent:IsNextBot()) or ent:Health() <= 0 then continue end
        if ent ~= selectedTarget then
            table.insert(otherHosts, ent)
        end
    end

    if #otherHosts > 0 then
        halo.Add(otherHosts, Color(220, 25, 25), 3, 3, 2, true, true)
    end

    if IsValid(selectedTarget) then
        halo.Add({selectedTarget}, Color(255, 60, 60), 6, 6, 3, true, true)
    end

    local ragdoll = ply:GetNWEntity("ST_DeathRagdoll")
    if IsValid(ragdoll) then
        halo.Add({ragdoll}, Color(70, 90, 110), 2, 2, 1, true, true)
    end
end)

hook.Add("KeyPress", "SoulTransfer_ConfirmInput", function(ply, key)
    if ply ~= LocalPlayer() then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if not isSpectral or isTransferring then return end

    if key == IN_ATTACK or key == IN_USE then
        local target = SoulTransfer.Targeting.CurrentTarget
        if IsValid(target) then
            net.Start("SoulTransfer_RequestPossess")
                net.WriteEntity(target)
            net.SendToServer()

            surface.PlaySound("buttons/button15.wav")
        end
    end
end)
