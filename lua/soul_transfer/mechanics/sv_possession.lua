SoulTransfer = SoulTransfer or {}
SoulTransfer.Possession = SoulTransfer.Possession or {}

function SoulTransfer.Possession.TransferSoul(ply, npc)
    if not IsValid(ply) or not IsValid(npc) then return false end

    SoulTransfer.Appearance.Log(ply, "TransferSoul iniciado: alvo=%s (%s) model=%s skin=%d",
        npc:GetClass(), tostring(npc), npc:GetModel(), npc:GetSkin() or 0)

    if not SoulTransfer.Appearance.CaptureFromNPC(ply, npc) then
        SoulTransfer.Appearance.Log(ply, "TransferSoul abortado: captura do corpo falhou (modelo invalido?).")
        SoulTransfer.CancelSpectral(ply)
        return false
    end

    local hostPos = npc:GetPos()
    local hostEyeAng = npc:EyeAngles()
    local hostHealth = npc:Health()
    local hostMaxHealth = npc:GetMaxHealth() > 0 and npc:GetMaxHealth() or 100
    local hostWeapon = npc:GetActiveWeapon()
    local weaponClass = IsValid(hostWeapon) and hostWeapon:GetClass() or nil
    local weaponClip = IsValid(hostWeapon) and hostWeapon:Clip1() or 0

    local timerName = "ST_Timeout_" .. ply:SteamID64()
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end

    npc:Remove()

    ply.ST_IsSpectral = false
    ply.ST_SelectedTarget = nil
    ply.ST_IsTransferring = false
    ply:SetNWBool("ST_IsSpectral", false)
    ply:SetNWBool("ST_IsTransferring", false)
    ply:SetNWEntity("ST_TargetEntity", NULL)

    ply.ST_SuppressLoadout = true
    if ply:GetObserverMode() ~= OBS_MODE_NONE then
        ply:UnSpectate()
    end
    ply:Spawn()
    ply.ST_SuppressLoadout = false
    ply.NextSpawnTime = nil

    SoulTransfer.Appearance.Log(ply, "Spawn concluido: alive=%s observerMode=%d model=%s",
        tostring(ply:Alive()), ply:GetObserverMode(), tostring(ply:GetModel()))

    ply:SetPos(hostPos)
    ply:SetEyeAngles(Angle(0, hostEyeAng.y, 0))

    local applied = SoulTransfer.Appearance.Apply(ply)
    ply:SetupHands()

    SoulTransfer.Appearance.Log(ply, "Apply apos Spawn: sucesso=%s model=%s skin=%d",
        tostring(applied), tostring(ply:GetModel()), ply:GetSkin())

    ply:SetNoDraw(false)
    ply:SetNotSolid(false)
    ply:UnLock()
    ply:DrawViewModel(true)

    local cv_preserve_hp = GetConVar("soultransfer_preserve_health")
    if cv_preserve_hp and cv_preserve_hp:GetBool() then
        ply:SetMaxHealth(hostMaxHealth)
        ply:SetHealth(math.Clamp(hostHealth, 1, hostMaxHealth))
    else
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
    end

    ply:StripWeapons()
    ply:StripAmmo()

    if weaponClass and weaponClass ~= "" then
        local givenWep = ply:Give(weaponClass)
        if IsValid(givenWep) then
            if weaponClip > 0 then
                givenWep:SetClip1(weaponClip)
            end
            ply:SelectWeapon(weaponClass)
        end
    end

    if game.SinglePlayer() then
        game.SetTimeScale(1.0)
        RunConsoleCommand("host_timescale", "1")
    end

    sound.Play("ambient/energy/zap7.wav", hostPos, 80, 110, 1)
    sound.Play("npc/stalker/stalker_scream" .. math.random(1, 4) .. ".wav", hostPos, 75, 130, 0.6)

    net.Start("SoulTransfer_PossessionSuccess")
        net.WriteVector(hostPos)
    net.Send(ply)

    SoulTransfer.Appearance.Log(ply, "Possessao concluida: model=%s skin=%d alive=%s",
        ply:GetModel(), ply:GetSkin(), tostring(ply:Alive()))

    timer.Simple(0.1, function()
        if not IsValid(ply) or not ply.ST_HostModel or not ply:Alive() then return end

        if ply:GetModel() ~= ply.ST_HostModel or ply:GetSkin() ~= (ply.ST_HostSkin or 0) then
            SoulTransfer.Appearance.Log(ply, "Verificacao 0.1s: aparencia divergiu (model=%s skin=%d); reaplicando corpo do hospedeiro.",
                tostring(ply:GetModel()), ply:GetSkin())
            SoulTransfer.Appearance.Apply(ply)
            ply:SetupHands()
        end
    end)

    SoulTransfer.Appearance.StartWatchdog(ply)

    return true
end
