AddCSLuaFile()

SoulTransfer = SoulTransfer or {}
SoulTransfer.Version = "1.0.0"
SoulTransfer.Name = "Soul Transfer"

if SERVER then
    AddCSLuaFile("soul_transfer/core/sh_config.lua")
    AddCSLuaFile("soul_transfer/core/sh_lang.lua")
    AddCSLuaFile("soul_transfer/core/cl_main.lua")
    AddCSLuaFile("soul_transfer/fx/cl_sounds.lua")
    AddCSLuaFile("soul_transfer/fx/cl_screen_fx.lua")
    AddCSLuaFile("soul_transfer/fx/cl_strands.lua")
    AddCSLuaFile("soul_transfer/mechanics/cl_targeting.lua")
    AddCSLuaFile("soul_transfer/ui/cl_hud.lua")
    AddCSLuaFile("soul_transfer/ui/cl_menu.lua")

    include("soul_transfer/core/sh_config.lua")
    include("soul_transfer/core/sh_lang.lua")
    include("soul_transfer/core/sv_main.lua")
    include("soul_transfer/mechanics/sv_targeting.lua")
    include("soul_transfer/mechanics/sv_appearance.lua")
    include("soul_transfer/mechanics/sv_possession.lua")

    print("[SoulTransfer] v" .. SoulTransfer.Version .. " carregado no servidor.")
else
    include("soul_transfer/core/sh_config.lua")
    include("soul_transfer/core/sh_lang.lua")
    include("soul_transfer/fx/cl_sounds.lua")
    include("soul_transfer/fx/cl_screen_fx.lua")
    include("soul_transfer/fx/cl_strands.lua")
    include("soul_transfer/mechanics/cl_targeting.lua")
    include("soul_transfer/ui/cl_hud.lua")
    include("soul_transfer/ui/cl_menu.lua")
    include("soul_transfer/core/cl_main.lua")

    print("[SoulTransfer] v" .. SoulTransfer.Version .. " carregado no cliente.")
end
