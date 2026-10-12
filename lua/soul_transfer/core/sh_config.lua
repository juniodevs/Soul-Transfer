SoulTransfer = SoulTransfer or {}
SoulTransfer.Config = SoulTransfer.Config or {}

CreateConVar("soultransfer_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Ativa ou desativa o mod Soul Transfer")
CreateConVar("soultransfer_range", "2500", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Alcance maximo em unidades para detectar NPCs para possessao")
CreateConVar("soultransfer_time_limit", "8", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Tempo maximo em segundos para escolher um corpo antes do respawn padrao")
CreateConVar("soultransfer_slomo", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Ativa camera lenta durante o modo astral no Singleplayer")
CreateConVar("soultransfer_preserve_health", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Mantem o HP atual do NPC possuido no jogador")
CreateConVar("soultransfer_allow_hostiles", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Permite possuir NPCs hostis")
CreateConVar("soultransfer_transfer_duration", "0.5", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Duracao do mergulho rapido da alma ate o corpo do NPC em segundos")

if CLIENT then
    CreateClientConVar("soultransfer_cl_blur", "1", true, false, "Ativa efeito de motion blur e distorcao de tela")
    CreateClientConVar("soultransfer_cl_strands", "1", true, false, "Ativa os feixes etereos conectando o cadaver aos NPCs")
    CreateClientConVar("soultransfer_cl_strands_dark", "0", true, false, "Feixe escuro (1) ou brilhante (0)")
    CreateClientConVar("soultransfer_cl_hud", "1", true, false, "Exibe HUD com cronometro e informacoes do NPC alvo")
    CreateClientConVar("soultransfer_cl_audio_volume", "1.0", true, false, "Volume geral dos sons de transicao de alma")
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
