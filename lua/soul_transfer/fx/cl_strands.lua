SoulTransfer = SoulTransfer or {}
SoulTransfer.Strands = SoulTransfer.Strands or {}

local matBeam = Material("sprites/physbeama")
local matGlow = Material("sprites/light_glow02_add")

local math_sin = math.sin
local math_cos = math.cos
local math_pi = math.pi
local CurTime = CurTime
local IsValid = IsValid
local Vector = Vector
local Color = Color

local function DrawEtherealStrand(startPos, endPos, isSelected, isDark, seed)
    local diff = endPos - startPos
    local dist = diff:Length()
    if dist < 8 then return end

    local dir = diff / dist
    local right = dir:Angle():Right()
    local up = dir:Angle():Up()

    local segments = 14
    local time = CurTime() * 2.2 + seed
    local pulseFrac = (CurTime() * 1.3 + (seed * 0.2)) % 1.0

    local coreColor, glowColor
    if isDark then
        coreColor = isSelected and Color(40, 10, 10, 240) or Color(20, 5, 5, 180)
        glowColor = isSelected and Color(25, 5, 5, 110) or Color(15, 0, 0, 70)
    else
        coreColor = isSelected and Color(255, 90, 90, 255) or Color(220, 45, 45, 180)
        glowColor = isSelected and Color(230, 20, 20, 130) or Color(160, 10, 10, 55)
    end

    local coreWidth = isSelected and 3.0 or 1.8
    local glowWidth = isSelected and 9.5 or 5.0

    render.SetMaterial(matBeam)

    render.StartBeam(segments + 1)
    for i = 0, segments do
        local frac = i / segments
        local lift = math_sin(frac * math_pi) * 8
        local w1 = math_sin(time + frac * 4.5) * 2.8 * math_sin(frac * math_pi)
        local w2 = math_cos(time * 0.8 + frac * 3.8) * 2.8 * math_sin(frac * math_pi)
        local pos = startPos + (diff * frac) + Vector(0, 0, lift) + (right * w1) + (up * w2)
        render.AddBeam(pos, glowWidth, frac, glowColor)
    end
    render.EndBeam()

    render.StartBeam(segments + 1)
    for i = 0, segments do
        local frac = i / segments
        local lift = math_sin(frac * math_pi) * 8
        local w1 = math_sin(time + frac * 4.5) * 2.8 * math_sin(frac * math_pi)
        local w2 = math_cos(time * 0.8 + frac * 3.8) * 2.8 * math_sin(frac * math_pi)
        local pos = startPos + (diff * frac) + Vector(0, 0, lift) + (right * w1) + (up * w2)
        render.AddBeam(pos, coreWidth, frac * 2, coreColor)
    end
    render.EndBeam()

    local pulsePos = startPos + (diff * pulseFrac) + Vector(0, 0, math_sin(pulseFrac * math_pi) * 8)
    render.SetMaterial(matGlow)
    render.DrawSprite(pulsePos, isSelected and 20 or 12, isSelected and 20 or 12, coreColor)
    render.DrawSprite(endPos, isSelected and 26 or 16, isSelected and 26 or 16, coreColor)
end

hook.Add("PostDrawTranslucentRenderables", "SoulTransfer_DrawStrands", function(bDepth, bSkybox)
    if bSkybox then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isSpectral = ply:GetNWBool("ST_IsSpectral", false)
    if not isSpectral then return end

    local cv_strands = GetConVar("soultransfer_cl_strands")
    if cv_strands and not cv_strands:GetBool() then return end

    local deathPos = ply:GetNWVector("ST_DeathPos", ply:GetPos())
    local ragdoll = ply:GetNWEntity("ST_DeathRagdoll")

    local originPos = deathPos + Vector(0, 0, 25)
    if IsValid(ragdoll) then
        local chestBone = ragdoll:LookupBone("ValveBiped.Bip01_Spine2") or ragdoll:LookupBone("ValveBiped.Bip01_Pelvis")
        if chestBone then
            local bPos = ragdoll:GetBonePosition(chestBone)
            if bPos then originPos = bPos end
        end
    end

    render.SetMaterial(matGlow)
    render.DrawSprite(originPos, 24, 24, Color(255, 60, 60, 230))

    local isDark = false
    local cv_dark = GetConVar("soultransfer_cl_strands_dark")
    if cv_dark then isDark = cv_dark:GetBool() end

    local currentSelected = SoulTransfer.Targeting.CurrentTarget
    local range = GetConVar("soultransfer_range"):GetFloat()

    for _, ent in ipairs(ents.FindInSphere(deathPos, range)) do
        if not IsValid(ent) or not (ent:IsNPC() or ent:IsNextBot()) or ent:Health() <= 0 then continue end

        local entPos = ent:EyePos() - Vector(0, 0, 8)
        local isSelected = (ent == currentSelected)

        DrawEtherealStrand(originPos, entPos, isSelected, isDark, ent:EntIndex())
    end
end)
