SoulTransfer = SoulTransfer or {}

local spectralStartTime = 0
local detachStartPos = Vector(0, 0, 0)
local detachStartAng = Angle(0, 0, 0)
local targetLookAng = Angle(0, 0, 0)
local flightStartTime = 0
local flightDuration = 0.5
local flightStartPos = Vector(0, 0, 0)
local flightTargetEnt = nil
local flightTargetPos = Vector(0, 0, 0)

local function SmoothAngleLerp(frac, fromAng, toAng)
    local p = Lerp(frac, fromAng.p, toAng.p)
    local diffY = math.NormalizeAngle(toAng.y - fromAng.y)
    local y = math.NormalizeAngle(fromAng.y + diffY * frac)
    local diffR = math.NormalizeAngle(toAng.r - fromAng.r)
    local r = math.NormalizeAngle(fromAng.r + diffR * frac)
    return Angle(p, y, r)
end

net.Receive("SoulTransfer_StartSpectral", function()
    local deathPos = net.ReadVector()
    local timeLimit = net.ReadFloat()
    local ragdoll = net.ReadEntity()
    local primaryHost = net.ReadEntity()

    spectralStartTime = RealTime()
    detachStartPos = deathPos + Vector(0, 0, 60)
    detachStartAng = LocalPlayer():EyeAngles()

    if IsValid(ragdoll) then
        local headBone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            local bPos = ragdoll:GetBonePosition(headBone)
            if bPos and bPos ~= vector_origin and bPos:DistToSqr(deathPos) < 40000 then
                detachStartPos = bPos
            end
        end
    end

    if IsValid(primaryHost) then
        SoulTransfer.Targeting.CurrentTarget = primaryHost
        local camElevated = deathPos + Vector(0, 0, 75)
        local dir = (primaryHost:WorldSpaceCenter() - camElevated):GetNormalized()
        targetLookAng = dir:Angle()
    else
        targetLookAng = detachStartAng
    end

    local cv_slomo = GetConVar("soultransfer_slomo")
    if game.SinglePlayer() and cv_slomo and cv_slomo:GetBool() then
        game.SetTimeScale(0.2)
        RunConsoleCommand("host_timescale", "0.2")
    end

    SoulTransfer.Audio.StartSpectralLoop()
end)

net.Receive("SoulTransfer_BeginFlight", function()
    flightTargetEnt = net.ReadEntity()
    flightDuration = net.ReadFloat()
    flightStartTime = RealTime()
    flightStartPos = EyePos()

    if IsValid(flightTargetEnt) then
        flightTargetPos = flightTargetEnt:EyePos()
    else
        flightTargetPos = flightStartPos
    end

    SoulTransfer.Audio.PlayDiveSound()
end)

net.Receive("SoulTransfer_PossessionSuccess", function()
    local arrivalPos = net.ReadVector()

    SoulTransfer.Audio.PlayArrivalSound()
    SoulTransfer.ScreenFX.TriggerArrivalFlash()

    flightTargetEnt = nil
end)

net.Receive("SoulTransfer_Cancel", function()
    SoulTransfer.Audio.PlayCancelSound()
    flightTargetEnt = nil
end)

local wrappedCalcHooks = {}
local wrappedHudHooks = {}

hook.Add("Think", "SoulTransfer_OverrideCompetingCameras", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if not isSpectral and not isTransferring then return end

    local calcTable = hook.GetTable()["CalcView"]
    if calcTable then
        for hookName, func in pairs(calcTable) do
            if hookName ~= "!!!SoulTransfer_AstralCamera" and not wrappedCalcHooks[hookName] then
                wrappedCalcHooks[hookName] = true
                local origFunc = func
                calcTable[hookName] = function(p, orig, angs, fov)
                    if IsValid(p) and (p:GetNWBool("ST_IsSpectral", false) or p:GetNWBool("ST_IsTransferring", false)) then
                        return
                    end
                    return origFunc(p, orig, angs, fov)
                end
            end
        end
    end

    local hudTable = hook.GetTable()["HUDPaint"]
    if hudTable and hudTable["JuniosRealism_BlackDeath"] and not wrappedHudHooks["JuniosRealism_BlackDeath"] then
        wrappedHudHooks["JuniosRealism_BlackDeath"] = true
        local origBlack = hudTable["JuniosRealism_BlackDeath"]
        hudTable["JuniosRealism_BlackDeath"] = function()
            local p = LocalPlayer()
            if IsValid(p) and (p:GetNWBool("ST_IsSpectral", false) or p:GetNWBool("ST_IsTransferring", false)) then
                return
            end
            return origBlack()
        end
    end
end)

hook.Add("CalcView", "!!!SoulTransfer_AstralCamera", function(ply, origin, angles, fov)
    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    local isTransferring = ply:GetNWBool("ST_IsTransferring", false)

    if not isSpectral and not isTransferring then return end

    local view = {}
    view.angles = angles
    view.drawviewer = true

    if isTransferring then
        local elapsed = RealTime() - flightStartTime
        local fraction = math.Clamp(elapsed / flightDuration, 0, 1)
        local easeFraction = math.ease.InQuad(fraction)

        local currentTargetPos = flightTargetPos
        if IsValid(flightTargetEnt) then
            currentTargetPos = flightTargetEnt:EyePos()
        end

        view.origin = LerpVector(easeFraction, flightStartPos, currentTargetPos)
        view.fov = fov + (math.sin(fraction * math.pi) * 28)
        view.drawviewer = true
        return view
    end

    if isSpectral then
        local deathPos = ply:GetNWVector("ST_DeathPos", origin)
        local camDist = 115

        local detachDuration = 1.0
        local elapsed = RealTime() - spectralStartTime

        local targetCamPos = deathPos + Vector(0, 0, 75) - (targetLookAng:Forward() * camDist)
        local tr = util.TraceHull({
            start = deathPos + Vector(0, 0, 45),
            endpos = targetCamPos,
            filter = { ply, ply:GetNWEntity("ST_DeathRagdoll") },
            mins = Vector(-6, -6, -6),
            maxs = Vector(6, 6, 6),
            mask = MASK_SOLID_BRUSHONLY
        })
        local finalCamPos = tr.Hit and (tr.HitPos + tr.HitNormal * 6) or targetCamPos

        if elapsed < detachDuration then
            local frac = math.Clamp(elapsed / detachDuration, 0, 1)
            local ease = math.ease.OutCubic(frac)

            view.origin = LerpVector(ease, detachStartPos, finalCamPos)
            view.angles = SmoothAngleLerp(ease, detachStartAng, targetLookAng)
            view.fov = fov + (math.sin(frac * math.pi) * 16)

            ply:SetEyeAngles(view.angles)
        else
            view.origin = finalCamPos
            view.angles = angles
            view.fov = fov
        end

        view.drawviewer = true
        return view
    end
end)
