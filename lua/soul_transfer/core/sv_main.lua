SoulTransfer = SoulTransfer or {}

util.AddNetworkString("SoulTransfer_StartSpectral")
util.AddNetworkString("SoulTransfer_RequestPossess")
util.AddNetworkString("SoulTransfer_BeginFlight")
util.AddNetworkString("SoulTransfer_PossessionSuccess")
util.AddNetworkString("SoulTransfer_Cancel")

function SoulTransfer.CancelSpectral(ply)
    if not IsValid(ply) then return end

    SoulTransfer.Appearance.Log(ply, "CancelSpectral chamado (voltando ao estado de morte padrao).")

    local timerName = "ST_Timeout_" .. ply:SteamID64()
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end

    local flightTimer = "ST_Flight_" .. ply:SteamID64()
    if timer.Exists(flightTimer) then
        timer.Remove(flightTimer)
    end

    ply.ST_IsSpectral = false
    ply.ST_IsTransferring = false
    ply.ST_SelectedTarget = nil
    ply:SetNWBool("ST_IsSpectral", false)
    ply:SetNWBool("ST_IsTransferring", false)
    ply:SetNWEntity("ST_TargetEntity", NULL)

    ply.NextSpawnTime = nil
    SoulTransfer.Appearance.ClearHost(ply, true)

    if game.SinglePlayer() then
        game.SetTimeScale(1.0)
        RunConsoleCommand("host_timescale", "1")
    end

    net.Start("SoulTransfer_Cancel")
    net.Send(ply)

    ply:Spectate(OBS_MODE_NONE)
end

hook.Add("PlayerDeath", "SoulTransfer_OnPlayerDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) or not victim:IsPlayer() then return end

    SoulTransfer.Appearance.ClearHost(victim, true)

    local cv_enabled = GetConVar("soultransfer_enabled")
    if not cv_enabled or not cv_enabled:GetBool() then return end

    local range = GetConVar("soultransfer_range"):GetFloat()
    local deathPos = victim:GetPos()

    local hosts = SoulTransfer.Targeting.GetNearbyHosts(deathPos, range, victim)
    if #hosts == 0 then
        victim:ChatPrint("[Soul Transfer] Nenhum NPC no alcance (" .. math.floor(range) .. "u). Spawne um NPC para possuir.")
        return
    end

    local closestHost = hosts[1]
    local closestDist = math.huge
    for _, h in ipairs(hosts) do
        local d = deathPos:DistToSqr(h:GetPos())
        if d < closestDist then
            closestDist = d
            closestHost = h
        end
    end

    victim:ChatPrint(string.format("[Soul Transfer] %d hospedeiro(s) no alcance. Mirar e clicar para transferir.", #hosts))

    local timeLimit = GetConVar("soultransfer_time_limit"):GetFloat()

    victim.ST_IsSpectral = true
    victim.ST_DeathPos = deathPos
    victim.ST_DeathRagdoll = victim:GetRagdollEntity()
    victim.ST_IsTransferring = false

    victim:SetNWBool("ST_IsSpectral", true)
    victim:SetNWBool("ST_IsTransferring", false)
    victim:SetNWVector("ST_DeathPos", deathPos)
    victim:SetNWFloat("ST_SoulStartTime", CurTime())
    victim:SetNWFloat("ST_SoulTimeLimit", timeLimit)
    victim:SetNWEntity("ST_DeathRagdoll", victim.ST_DeathRagdoll)

    victim:Spectate(OBS_MODE_ROAMING)
    timer.Simple(0, function()
        if IsValid(victim) and victim.ST_IsSpectral then
            victim:Spectate(OBS_MODE_ROAMING)
        end
    end)
    timer.Simple(0.08, function()
        if IsValid(victim) and victim.ST_IsSpectral then
            victim:Spectate(OBS_MODE_ROAMING)
        end
    end)

    local cv_slomo = GetConVar("soultransfer_slomo")
    if game.SinglePlayer() and cv_slomo and cv_slomo:GetBool() then
        game.SetTimeScale(0.2)
        RunConsoleCommand("host_timescale", "0.2")
    end

    net.Start("SoulTransfer_StartSpectral")
        net.WriteVector(deathPos)
        net.WriteFloat(timeLimit)
        net.WriteEntity(victim.ST_DeathRagdoll)
        net.WriteEntity(closestHost)
    net.Send(victim)

    local timerName = "ST_Timeout_" .. victim:SteamID64()
    timer.Create(timerName, timeLimit, 1, function()
        if IsValid(victim) and victim.ST_IsSpectral and not victim.ST_IsTransferring then
            SoulTransfer.CancelSpectral(victim)
        end
    end)
end)

hook.Add("PlayerDeathThink", "SoulTransfer_PreventInstantRespawn", function(ply)
    if ply.ST_IsSpectral or ply.ST_IsTransferring then
        ply.NextSpawnTime = CurTime() + 3600
        return false
    end
end)

hook.Add("PlayerLoadout", "SoulTransfer_SuppressLoadout", function(ply)
    if ply.ST_SuppressLoadout then
        return true
    end
end)

net.Receive("SoulTransfer_RequestPossess", function(len, ply)
    if not IsValid(ply) or not ply.ST_IsSpectral or ply.ST_IsTransferring then return end

    local targetNPC = net.ReadEntity()
    local range = GetConVar("soultransfer_range"):GetFloat()

    if not SoulTransfer.Targeting.ValidateTarget(targetNPC, ply, range) then
        SoulTransfer.Appearance.Log(ply, "Pedido de possessao rejeitado: alvo invalido (%s).", tostring(targetNPC))
        return
    end

    SoulTransfer.Appearance.Log(ply, "Pedido de possessao aceito: alvo=%s.", tostring(targetNPC))

    ply.ST_IsTransferring = true
    ply.ST_SelectedTarget = targetNPC
    ply:SetNWBool("ST_IsTransferring", true)
    ply:SetNWEntity("ST_TargetEntity", targetNPC)

    local duration = math.Clamp(GetConVar("soultransfer_transfer_duration"):GetFloat(), 0.2, 1.5)
    local cv_slomo = GetConVar("soultransfer_slomo")
    local timerDuration = (game.SinglePlayer() and cv_slomo and cv_slomo:GetBool()) and (duration * 0.2) or duration

    net.Start("SoulTransfer_BeginFlight")
        net.WriteEntity(targetNPC)
        net.WriteFloat(duration)
    net.Send(ply)

    local flightTimer = "ST_Flight_" .. ply:SteamID64()
    timer.Create(flightTimer, timerDuration, 1, function()
        if IsValid(ply) and IsValid(targetNPC) then
            SoulTransfer.Possession.TransferSoul(ply, targetNPC)
        else
            SoulTransfer.CancelSpectral(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "SoulTransfer_CleanupPlayer", function(ply)
    if not IsValid(ply) then return end
    local timerName = "ST_Timeout_" .. ply:SteamID64()
    if timer.Exists(timerName) then timer.Remove(timerName) end
    local flightTimer = "ST_Flight_" .. ply:SteamID64()
    if timer.Exists(flightTimer) then timer.Remove(flightTimer) end

    if game.SinglePlayer() then
        game.SetTimeScale(1.0)
        RunConsoleCommand("host_timescale", "1")
    end
end)
