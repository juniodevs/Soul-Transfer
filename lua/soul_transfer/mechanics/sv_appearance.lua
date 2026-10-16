SoulTransfer = SoulTransfer or {}
SoulTransfer.Appearance = SoulTransfer.Appearance or {}

local RAW_PLAYER_SETMODEL = FindMetaTable("Player").SetModel
local RAW_ENTITY_SETMODEL = FindMetaTable("Entity").SetModel

local function DescribeFn(fn, label)
    if type(fn) ~= "function" then return label .. "=ausente" end

    local ok, info = pcall(debug.getinfo, fn, "S")
    if not ok or not info then return label .. "=indescritivel" end

    if info.what == "C" then return label .. "=C (engine)" end
    return label .. "=Lua (" .. tostring(info.short_src) .. ":" .. tostring(info.linedefined) .. ")"
end

SoulTransfer.Appearance.DescribeFn = DescribeFn
SoulTransfer.Appearance.RawSetModel = RAW_ENTITY_SETMODEL

function SoulTransfer.Appearance.IsDebugEnabled()
    local cv = GetConVar("soultransfer_debug")
    return cv ~= nil and cv:GetBool()
end

function SoulTransfer.Appearance.Log(ply, fmt, ...)
    if not SoulTransfer.Appearance.IsDebugEnabled() then return end

    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then msg = tostring(fmt) end

    print("[SoulTransfer][Debug] " .. msg)

    if IsValid(ply) and ply:IsPlayer() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[SoulTransfer] " .. msg)
    end
end

local indexSet = nil
local indexSorted = nil
local linkCache = {}

local function ConsiderModel(target, value, key)
    local candidate

    if isstring(value) and string.sub(value, -4) == ".mdl" then
        candidate = value
    elseif isstring(key) and string.sub(key, -4) == ".mdl" then
        candidate = key
    end

    if not candidate then return end

    local lc = string.lower(candidate)
    if target.set[lc] then return end

    target.set[lc] = true
    target.sorted[#target.sorted + 1] = lc
end

function SoulTransfer.Appearance.BuildModelIndex()
    local target = { set = {}, sorted = {} }

    if player_manager and player_manager.AllValidModels then
        for key, value in pairs(player_manager.AllValidModels()) do
            ConsiderModel(target, value, key)
        end
    end

    if list and list.Get then
        for key, value in pairs(list.Get("PlayerOptionsModel") or {}) do
            ConsiderModel(target, value, key)
        end
    end

    table.sort(target.sorted)

    indexSet = target.set
    indexSorted = target.sorted
    linkCache = {}

    SoulTransfer.Appearance.Log(nil, "Index de playermodels: %d modelos validos catalogados.", #indexSorted)
end

local function CandidateInIndex(dir, name)
    local path = dir .. name .. ".mdl"
    if indexSet[path] then return path end
    return nil
end

function SoulTransfer.Appearance.FindLinkedPlayermodel(npcModel)
    if not isstring(npcModel) or npcModel == "" then return nil end
    if not indexSet then SoulTransfer.Appearance.BuildModelIndex() end

    local cached = linkCache[npcModel]
    if cached ~= nil then return cached or nil end

    local lc = string.lower(npcModel)
    local result

    if indexSet[lc] then
        result = lc
    else
        local dir, stem = string.match(lc, "^(.*/)([^/]+)%.mdl$")

        if dir then
            local base = string.gsub(stem, "_npc%d*$", "")
            if base == "" then base = stem end

            result = CandidateInIndex(dir, base)
                or CandidateInIndex(dir, base .. "_pm")
                or CandidateInIndex(dir, base .. "_player")
                or CandidateInIndex(dir, base .. "_playermodel")
                or (base ~= stem and CandidateInIndex(dir, stem .. "_pm"))
                or nil

            if not result then
                local names = { base }
                if base ~= stem then names[#names + 1] = stem end

                local sub = string.match(lc, "^models/([^/]+)/")

                for _, name in ipairs(names) do
                    result = CandidateInIndex("models/player/", name)
                    if not result and sub then
                        result = CandidateInIndex("models/player/", sub .. "_" .. name)
                    end
                    if result then break end
                end
            end

            if not result then
                local prefixes = { dir .. base .. "_" }
                if base ~= stem then prefixes[#prefixes + 1] = dir .. stem .. "_" end

                for _, pm in ipairs(indexSorted) do
                    for _, prefix in ipairs(prefixes) do
                        if string.sub(pm, 1, #prefix) == prefix then
                            result = pm
                            break
                        end
                    end
                    if result then break end
                end
            end
        end
    end

    linkCache[npcModel] = result or false
    return result
end

function SoulTransfer.Appearance.CaptureFromNPC(ply, npc)
    if not IsValid(ply) or not IsValid(npc) then return false end

    local model = npc:GetModel()
    if not model or model == "" then return false end
    if not util.IsValidModel(model) then return false end

    util.PrecacheModel(model)

    ply.ST_HostModel = model
    ply.ST_HostPlayermodel = SoulTransfer.Appearance.FindLinkedPlayermodel(model)
    ply.ST_HostExact = ply.ST_HostPlayermodel ~= nil and string.lower(ply.ST_HostPlayermodel) == string.lower(model)

    ply.ST_HostSkin = npc:GetSkin() or 0

    local bodygroups = {}
    for i = 0, npc:GetNumBodyGroups() - 1 do
        bodygroups[i] = npc:GetBodygroup(i)
    end
    ply.ST_HostBodygroups = bodygroups

    local scale = npc:GetModelScale()
    ply.ST_HostScale = (scale and scale > 0) and scale or 1
    ply.ST_HostMaterial = npc:GetMaterial() or ""
    ply.ST_HostColor = npc:GetColor()

    SoulTransfer.Appearance.Log(ply, "Corpo capturado de %s: model=%s playermodel=%s exact=%s skin=%d bgroups=%d scale=%.2f",
        npc:GetClass(), model, tostring(ply.ST_HostPlayermodel), tostring(ply.ST_HostExact), ply.ST_HostSkin, table.Count(bodygroups), ply.ST_HostScale)

    return true
end

function SoulTransfer.Appearance.Apply(ply)
    if not IsValid(ply) or not ply.ST_HostModel then return false end
    if not util.IsValidModel(ply.ST_HostModel) then return false end

    local pm = ply.ST_HostPlayermodel

    if not pm then
        return true
    end

    if ply:GetModel() ~= pm then
        ply:SetModel(pm)

        local after = ply:GetModel()
        if after ~= pm then
            local okRaw, errRaw = pcall(RAW_ENTITY_SETMODEL, ply, pm)
            local afterRaw = ply:GetModel()

            if not ply.ST_SetModelDiagDone then
                ply.ST_SetModelDiagDone = true

                SoulTransfer.Appearance.Log(ply, "SetModel via metodo falhou (resultado=%s); tentativa via Entity raw: ok=%s err=%s resultado=%s",
                    tostring(after), tostring(okRaw), tostring(errRaw), tostring(afterRaw))

                SoulTransfer.Appearance.Log(ply, "Metatables: %s | %s",
                    DescribeFn(RAW_PLAYER_SETMODEL, "Player.SetModel"),
                    DescribeFn(RAW_ENTITY_SETMODEL, "Entity.SetModel"))
            end
        end
    end

    if ply.ST_HostExact then
        ply:SetSkin(ply.ST_HostSkin or 0)

        local bodygroups = ply.ST_HostBodygroups
        if bodygroups then
            local numGroups = ply:GetNumBodyGroups()
            for i = 0, numGroups - 1 do
                if bodygroups[i] ~= nil then
                    ply:SetBodygroup(i, bodygroups[i])
                end
            end
        end
    else
        ply:SetSkin(0)
    end

    if ply.ST_HostScale and ply.ST_HostScale ~= 1 then
        ply:SetModelScale(ply.ST_HostScale, 0)
    end

    ply:SetMaterial(ply.ST_HostMaterial or "")
    if ply.ST_HostColor then
        ply:SetColor(ply.ST_HostColor)
    end

    return ply:GetModel() == pm
end

function SoulTransfer.Appearance.ClearHost(ply, restoreNow)
    if not IsValid(ply) then return end

    SoulTransfer.Appearance.StopWatchdog(ply)

    local hadHost = ply.ST_HostModel ~= nil

    ply.ST_HostModel = nil
    ply.ST_HostPlayermodel = nil
    ply.ST_HostExact = nil
    ply.ST_HostSkin = nil
    ply.ST_HostBodygroups = nil
    ply.ST_HostScale = nil
    ply.ST_HostMaterial = nil
    ply.ST_HostColor = nil
    ply.ST_SetModelDiagDone = nil

    if restoreNow and hadHost then
        ply:SetModelScale(1, 0)
        ply:SetMaterial("")
        ply:SetColor(Color(255, 255, 255, 255))
    end

    if hadHost then
        SoulTransfer.Appearance.Log(ply, "Estado do corpo hospedeiro limpo (restoreNow=%s)", tostring(restoreNow == true))
    end
end

local watchdogCounter = 0

function SoulTransfer.Appearance.StartWatchdog(ply)
    if not IsValid(ply) or not ply.ST_HostModel then return end

    SoulTransfer.Appearance.StopWatchdog(ply)

    watchdogCounter = watchdogCounter + 1
    local id = watchdogCounter
    ply.ST_WatchdogId = id

    local timerName = "ST_Watchdog_" .. id
    timer.Create(timerName, 0.25, 0, function()
        if not IsValid(ply) or ply.ST_WatchdogId ~= id then
            timer.Remove(timerName)
            return
        end

        if not ply.ST_HostModel then
            ply.ST_WatchdogId = nil
            timer.Remove(timerName)
            return
        end

        if not ply:Alive() then return end

        local pm = ply.ST_HostPlayermodel
        if not pm then return end

        local model = ply:GetModel()
        local skin = ply:GetSkin()
        local skinBad = ply.ST_HostExact and skin ~= (ply.ST_HostSkin or 0)

        if model ~= pm or skinBad then
            SoulTransfer.Appearance.Log(ply, "Watchdog: aparencia divergiu (model=%s skin=%d, esperado=%s skin=%d); reaplicando corpo.",
                tostring(model), skin, pm, ply.ST_HostSkin or 0)
            SoulTransfer.Appearance.Apply(ply)
        end
    end)
end

function SoulTransfer.Appearance.StopWatchdog(ply)
    if not IsValid(ply) then return end

    local id = ply.ST_WatchdogId
    if id then
        ply.ST_WatchdogId = nil
        timer.Remove("ST_Watchdog_" .. id)
    end
end

hook.Add("PlayerSetModel", "SoulTransfer_HostBody", function(ply)
    if not IsValid(ply) or not ply.ST_HostModel then return end
    if not ply.ST_HostPlayermodel then return end

    SoulTransfer.Appearance.Log(ply, "PlayerSetModel interceptado: reaplicando playermodel %s.", ply.ST_HostPlayermodel)
    SoulTransfer.Appearance.Apply(ply)
    return true
end)

hook.Add("PlayerSpawn", "SoulTransfer_HostBodyReapply", function(ply)
    if not IsValid(ply) or not ply.ST_HostModel then return end

    SoulTransfer.Appearance.Log(ply, "PlayerSpawn com corpo hospedeiro ativo; agendando reaplicacao.")

    timer.Simple(0, function()
        if IsValid(ply) and ply:Alive() and ply.ST_HostModel then
            SoulTransfer.Appearance.Apply(ply)
            ply:SetupHands()
        end
    end)
end)

hook.Add("DoPlayerDeath", "SoulTransfer_ClearHostOnDeath", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    SoulTransfer.Appearance.ClearHost(ply, true)
end)

hook.Add("InitPostEntity", "SoulTransfer_BuildModelIndex", function()
    SoulTransfer.Appearance.BuildModelIndex()
end)

local function SoulTransferIsUselessModel(model)
    if util.IsUselessModel then
        local ok, res = pcall(util.IsUselessModel, model)
        if ok then return res end
    end
    if UTIL_IsUselessModel then
        local ok, res = pcall(UTIL_IsUselessModel, model)
        if ok then return res end
    end
    return "n/a"
end

concommand.Add("soultransfer_modelselftest", function(ply, cmd, args)
    local target
    if IsValid(ply) then
        if game.IsDedicated() and not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTCONSOLE, "[SoulTransfer] Apenas admin pode rodar este teste.")
            return
        end
        target = ply
    else
        target = Entity(1)
    end

    if not IsValid(target) or not target:IsPlayer() then return end

    local hostModel = (args and args[1]) or target.ST_HostModel or "models/combine_soldier.mdl"

    local tests = {
        hostModel,
        "models/player/alyx.mdl",
        "models/player/kleiner.mdl",
    }

    local original = target:GetModel()
    print(string.format("[SoulTransfer][Test] Modelo atual: %s (skin %d)",
        tostring(original), target:GetSkin()))
    print(string.format("[SoulTransfer][Test] Metatables: %s | %s",
        DescribeFn(RAW_PLAYER_SETMODEL, "Player.SetModel"),
        DescribeFn(RAW_ENTITY_SETMODEL, "Entity.SetModel")))

    SoulTransfer.Appearance.BuildModelIndex()
    print(string.format("[SoulTransfer][Test] Playermodels validos catalogados: %d", #indexSorted))

    for _, m in ipairs(tests) do
        local valid = util.IsValidModel(m)
        local useless = SoulTransferIsUselessModel(m)
        local linked = SoulTransfer.Appearance.FindLinkedPlayermodel(m)

        local okMethod, errMethod = pcall(function() target:SetModel(m) end)
        local afterMethod = target:GetModel()

        local okRaw, errRaw = pcall(RAW_ENTITY_SETMODEL, target, m)
        local afterRaw = target:GetModel()

        print(string.format("[SoulTransfer][Test] %s | playermodel vinculado=%s | IsValidModel=%s IsUseless=%s | metodo: err=%s modelo=%s MUDOU=%s | raw: err=%s modelo=%s MUDOU=%s",
            m, tostring(linked), tostring(valid), tostring(useless),
            tostring(errMethod), tostring(afterMethod), tostring(afterMethod == m),
            tostring(okRaw), tostring(errRaw), tostring(afterRaw), tostring(afterRaw == m)))
    end

    target:SetModel(original)
    print("[SoulTransfer][Test] Modelo restaurado: " .. tostring(target:GetModel()))
end)
