SoulTransfer = SoulTransfer or {}
SoulTransfer.Possession = SoulTransfer.Possession or {}

function SoulTransfer.Possession.TransferSoul(ply, npc)
    if not IsValid(ply) or not IsValid(npc) then return false end

    local hostModel = npc:GetModel()
    local hostSkin = npc:GetSkin()
    local hostPos = npc:GetPos()
    local hostAng = npc:GetAngles()
    local hostEyeAng = npc:EyeAngles()
    local hostHealth = npc:Health()
    local hostMaxHealth = npc:GetMaxHealth() > 0 and npc:GetMaxHealth() or 100
    local hostWeapon = npc:GetActiveWeapon()
    local weaponClass = IsValid(hostWeapon) and hostWeapon:GetClass() or nil
    local weaponClip = IsValid(hostWeapon) and hostWeapon:Clip1() or 0

    local bodygroups = {}
    for i = 0, npc:GetNumBodyGroups() - 1 do
        bodygroups[i] = npc:GetBodygroup(i)
    end

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
    ply:Spawn()
    ply.ST_SuppressLoadout = false

    ply:SetPos(hostPos)
    ply:SetEyeAngles(Angle(0, hostEyeAng.y, 0))
    ply:SetModel(hostModel)
    ply:SetSkin(hostSkin)

    for bgIndex, bgVal in pairs(bodygroups) do
        ply:SetBodygroup(bgIndex, bgVal)
    end

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

    return true
end
