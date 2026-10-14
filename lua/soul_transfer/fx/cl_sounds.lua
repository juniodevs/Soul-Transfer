SoulTransfer = SoulTransfer or {}
SoulTransfer.Audio = SoulTransfer.Audio or {}

local spiritLoopSound = nil

function SoulTransfer.Audio.StartSpectralLoop()
    SoulTransfer.Audio.StopSpectralLoop()

    local vol = GetConVar("soultransfer_cl_audio_volume"):GetFloat()
    local ply = LocalPlayer()
    if IsValid(ply) then
        spiritLoopSound = CreateSound(ply, "ambient/atmosphere/underground_hall_loop1.wav")
        if spiritLoopSound then
            spiritLoopSound:PlayEx(vol * 0.7, 85)
        end
    end

    surface.PlaySound("ambient/levels/citadel/portal_beam_shoot5.wav")
end

function SoulTransfer.Audio.StopSpectralLoop()
    if spiritLoopSound then
        spiritLoopSound:Stop()
        spiritLoopSound = nil
    end
end

function SoulTransfer.Audio.PlayDiveSound()
    SoulTransfer.Audio.StopSpectralLoop()
    surface.PlaySound("ambient/levels/citadel/portal_beam_shoot1.wav")
    surface.PlaySound("ambient/energy/wisp10.wav")
end

function SoulTransfer.Audio.PlayArrivalSound()
    surface.PlaySound("ambient/energy/zap1.wav")
    surface.PlaySound("npc/barnacle/neck_snap1.wav")
end

function SoulTransfer.Audio.PlayCancelSound()
    SoulTransfer.Audio.StopSpectralLoop()
    surface.PlaySound("ambient/levels/citadel/weapon_disintegrate2.wav")
end
