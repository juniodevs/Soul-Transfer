SoulTransfer = SoulTransfer or {}
SoulTransfer.Targeting = SoulTransfer.Targeting or {}

function SoulTransfer.Targeting.IsValidHost(ent, ply)
    if not IsValid(ent) then return false end
    if not (ent:IsNPC() or ent:IsNextBot()) then return false end
    if ent:Health() <= 0 then return false end

    local class = string.lower(ent:GetClass())
    if SoulTransfer.Config.BlacklistedClasses[class] then
        return false
    end

    local model = ent:GetModel()
    if not model or model == "" then return false end

    local cv_hostiles = GetConVar("soultransfer_allow_hostiles")
    if cv_hostiles and not cv_hostiles:GetBool() then
        if IsValid(ply) and ent.Disposition and ent:Disposition(ply) == D_HT then
            return false
        end
    end

    return true
end

function SoulTransfer.Targeting.GetNearbyHosts(pos, maxDist, ply)
    local hosts = {}
    local maxDistSq = maxDist * maxDist

    for _, ent in ipairs(ents.FindInSphere(pos, maxDist)) do
        if SoulTransfer.Targeting.IsValidHost(ent, ply) then
            local distSq = ent:GetPos():DistToSqr(pos)
            if distSq <= maxDistSq then
                table.insert(hosts, ent)
            end
        end
    end

    return hosts
end

function SoulTransfer.Targeting.ValidateTarget(target, ply, maxDist)
    if not SoulTransfer.Targeting.IsValidHost(target, ply) then return false end
    if not IsValid(ply) then return false end

    local deathPos = ply.ST_DeathPos or ply:GetPos()
    if target:GetPos():Distance(deathPos) > (maxDist + 300) then
        return false
    end

    return true
end
