SoulTransfer = SoulTransfer or {}
SoulTransfer.Lang = SoulTransfer.Lang or {}

local phrases = {
    pt = {
        menu_title = "Configurações",
        menu_desc = "Opções do mod Soul Transfer.",
        cat_general = "Geral",
        cat_client = "Visual e Áudio",

        opt_enabled = "Ativar Soul Transfer",
        opt_enabled_help = "Ativa a troca de corpo ao morrer.",
        opt_range = "Distância Máxima",
        opt_range_help = "Distância limite para achar NPCs no mapa.",
        opt_time_limit = "Tempo de Escolha",
        opt_time_limit_help = "Segundos para escolher um NPC antes de morrer normal.",
        opt_slomo = "Câmera Lenta (Singleplayer)",
        opt_slomo_help = "Reduz a velocidade do jogo enquanto escolhe o corpo.",
        opt_preserve_hp = "Manter Vida do NPC",
        opt_preserve_hp_help = "Começa no corpo novo com a vida que o NPC tinha.",
        opt_allow_hostiles = "Permitir NPCs Inimigos",
        opt_allow_hostiles_help = "Permite entrar em Combine, Zumbis e outros inimigos.",
        opt_transfer_duration = "Tempo de Transição",
        opt_transfer_duration_help = "Tempo do voo até o corpo em segundos.",

        opt_cl_blur = "Efeitos de Tela",
        opt_cl_blur_help = "Ativa desfoque e distorção na transição.",
        opt_cl_strands = "Feixes de Alma",
        opt_cl_strands_help = "Mostra as linhas de energia ligando o corpo aos NPCs.",
        opt_cl_strands_dark = "Feixe Escuro",
        opt_cl_strands_dark_help = "Alterna entre feixe brilhante ou escuro.",
        opt_cl_hud = "Mostrar HUD",
        opt_cl_hud_help = "Mostra o tempo restante e dados do alvo na tela.",
        opt_cl_volume = "Volume dos Sons",
        opt_cl_volume_help = "Volume dos efeitos de som do mod.",

        hud_time_left = "TEMPO RESTANTE: %.1fs",
        hud_choose_target = "MIRE NO NPC E CLIQUE OU APERTE [E]",
        hud_no_targets = "NENHUM NPC POR PERTO",
        hud_target_info = "ALVO: %s | VIDA: %d",
        hud_transferring = "ENTRANDO NO CORPO...",
    },
    en = {
        menu_title = "Settings",
        menu_desc = "Soul Transfer mod options.",
        cat_general = "General",
        cat_client = "Visual & Audio",

        opt_enabled = "Enable Soul Transfer",
        opt_enabled_help = "Enables transferring to NPCs on death.",
        opt_range = "Max Range",
        opt_range_help = "Maximum distance to detect nearby NPCs.",
        opt_time_limit = "Selection Time",
        opt_time_limit_help = "Seconds allowed to pick an NPC before dying normally.",
        opt_slomo = "Slow Motion (Singleplayer)",
        opt_slomo_help = "Slows down time while choosing a target.",
        opt_preserve_hp = "Keep NPC Health",
        opt_preserve_hp_help = "Start in the new body with the health the NPC had.",
        opt_allow_hostiles = "Allow Hostile NPCs",
        opt_allow_hostiles_help = "Allows taking over Combines, Zombies, and other hostiles.",
        opt_transfer_duration = "Transition Duration",
        opt_transfer_duration_help = "Flight duration into the host body in seconds.",

        opt_cl_blur = "Screen Effects",
        opt_cl_blur_help = "Enables blur and distortion during transition.",
        opt_cl_strands = "Soul Beams",
        opt_cl_strands_help = "Shows energy beams connecting your body to NPCs.",
        opt_cl_strands_dark = "Dark Beams",
        opt_cl_strands_dark_help = "Toggles between glowing beams or dark strands.",
        opt_cl_hud = "Show HUD",
        opt_cl_hud_help = "Shows remaining time and target info.",
        opt_cl_volume = "Sound Volume",
        opt_cl_volume_help = "Volume for mod sound effects.",

        hud_time_left = "TIME REMAINING: %.1fs",
        hud_choose_target = "AIM AT NPC AND CLICK OR PRESS [E]",
        hud_no_targets = "NO NEARBY NPCS FOUND",
        hud_target_info = "TARGET: %s | HP: %d",
        hud_transferring = "ENTERING HOST...",
    }
}

function SoulTransfer.T(key, ...)
    local lang = "en"
    if GetConVar("gmod_language") then
        local gLang = string.lower(GetConVar("gmod_language"):GetString())
        if string.find(gLang, "pt") then
            lang = "pt"
        end
    end

    local langTable = phrases[lang] or phrases["en"]
    local text = langTable[key] or phrases["en"][key] or key

    if ... then
        return string.format(text, ...)
    end
    return text
end
