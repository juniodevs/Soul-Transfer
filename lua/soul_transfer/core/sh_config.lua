SoulTransfer = SoulTransfer or {}
SoulTransfer.Config = SoulTransfer.Config or {}

CreateConVar("soultransfer_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable or disable the Soul Transfer mod")
CreateConVar("soultransfer_range", "2500", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Maximum distance in units to detect NPCs for possession")
CreateConVar("soultransfer_time_limit", "8", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Maximum time in seconds to choose a host before normal death")
CreateConVar("soultransfer_slomo", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable slow motion during spectral mode in singleplayer")
CreateConVar("soultransfer_preserve_health", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Keep the possessed NPC's current health on the player")
CreateConVar("soultransfer_allow_hostiles", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Allow possessing hostile NPCs")
CreateConVar("soultransfer_transfer_duration", "0.5", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Flight duration into the host body in seconds")
CreateConVar("soultransfer_debug", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Print body transfer diagnostic logs to console")

if CLIENT then
    CreateClientConVar("soultransfer_cl_blur", "1", true, false, "Enable motion blur and screen distortion")
    CreateClientConVar("soultransfer_cl_strands", "1", true, false, "Enable ethereal strands connecting corpse to NPCs")
    CreateClientConVar("soultransfer_cl_strands_dark", "0", true, false, "Dark strands (1) or glowing strands (0)")
    CreateClientConVar("soultransfer_cl_hud", "1", true, false, "Display HUD with timer and target NPC info")
    CreateClientConVar("soultransfer_cl_audio_volume", "1.0", true, false, "Overall volume for soul transfer sound effects")
end

SoulTransfer.Config.BlacklistedClasses = {
    ["npc_strider"] = true,
    ["npc_combinegunship"] = true,
    ["npc_helicopter"] = true,
    ["npc_cscanner"] = true,
    ["npc_clawscanner"] = true,
    ["npc_manhack"] = true,
    ["npc_rollermine"] = true,
    ["npc_turret_floor"] = true,
    ["npc_turret_ceiling"] = true,
    ["npc_antlionguard"] = true,
    ["npc_headcrab"] = true,
    ["npc_headcrab_fast"] = true,
    ["npc_headcrab_black"] = true,
    ["npc_pigeon"] = true,
    ["npc_crow"] = true,
    ["npc_seagull"] = true,
}
