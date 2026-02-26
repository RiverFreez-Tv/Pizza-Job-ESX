local NPC = {}
local npcId = 0
local currentNPC = nil
local cam
local camRotation
local interect = false
local dialog = {}

local function CreateCam()
    local px, py, pz = table.unpack(GetEntityCoords(currentNPC.npc, true))
    local x, y, z = px + GetEntityForwardX(currentNPC.npc) * 1.2, py + GetEntityForwardY(currentNPC.npc) * 1.2,
        pz + 0.52
    local rx = GetEntityRotation(currentNPC.npc, 2)
    camRotation = rx + vector3(0.0, 0.0, 181.0)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, camRotation, GetGameplayCamFov())
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, 1, 1)
end

local function changeDialog(_label, _elements)
    local cloneE = {}
    for k,v in pairs (_elements) do
       if v.canInteract then
            local success, resp = pcall(v.canInteract)
            if success and resp then
                cloneE[#cloneE+1] = v
            end
       else
            cloneE[#cloneE+1] = v
       end
    end
    SendReactMessage("changeDialog", {
        msg = _label, -- thanh tin nhắn
        elements = cloneE
    })
    dialog = cloneE
end

local function updateMessage(label)
    SendReactMessage("updateMessage", {
        msg = label
    })
end

local function talkNPC(_id)
    local npc = NPC[_id]
    currentNPC = npc
    CreateCam()
    interect = true
    SetNuiFocus(true, true)
    
    if npc.onInteract then
        npc.onInteract()
    end

    local cloneE = {}
    for k,v in pairs (npc.elements) do
       if v.canInteract then
            local success, resp = pcall(v.canInteract)
            if success and resp then
                cloneE[#cloneE+1] = v
            end
       else
            cloneE[#cloneE+1] = v
       end
    end
    SendReactMessage("show", {
        msg = npc.startMSG,
        elements = cloneE,
        npcName = npc.name,
        npcTag = npc.tag,
        npcColor = npc.color
    })
    dialog = cloneE
end

local function CreateNPC(_pedData, _elements)
    npcId = npcId + 1
    if type(_pedData.npc) ~= 'number' then _pedData.npc = joaat(_pedData.npc) end
    if HasModelLoaded(_pedData.npc) then
        goto skip
    else
        if not IsModelValid(_pedData.npc) and not IsModelInCdimage(_pedData.npc) then
            return
        end
    end
    RequestModel(_pedData.npc)
    while not HasModelLoaded(_pedData.npc) do
        Wait(1)
    end
    ::skip::
    local ped = CreatePed(0, _pedData.npc, _pedData.coords.x, _pedData.coords.y, _pedData.coords.z, _pedData.coords.w, false, true)
    SetPedDefaultComponentVariation(ped)
    SetEntityHeading(ped, _pedData.coords.w)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedDiesWhenInjured(ped, false)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3)
    SetModelAsNoLongerNeeded(_pedData.npc)
    if _pedData.animName then
        RequestAnimDict(_pedData.animName)
        while not HasAnimDictLoaded(_pedData.animName) do
            Wait(1)
        end
        TaskPlayAnim(ped, _pedData.animName, _pedData.animDist, 8.0, 0.0, -1, 1, 0, false, false, false)
    elseif _pedData.animScenario then
        TaskStartScenarioInPlace(ped, _pedData.animScenario, 0, true)
    end

    local invoking = GetInvokingResource() or GetCurrentResourceName()
    
    local prompt = vPrompt:Create({
        key = 'E',
        label = Config.Talk:format(_pedData.name),
        entity = ped,
        drawDistance = 4.0,
        interactDistance = 2.0,
    })

    prompt:On('interact', function()
        talkNPC(ped)
    end)

    NPC[ped] = {
        id = npcId,
        npc = ped,
        prompt = prompt,
        resource = invoking,
        coords = _pedData.coords,
        name = _pedData.name,
        tag = _pedData.tag,
        color = _pedData.color,
        startMSG = _pedData.startMSG or 'Hello',
        elements = _elements,
        onInteract = _pedData.onInteract
    }
    return ped
end

RegisterNUICallback('close', function(_, cb)
    currentNPC = nil
    interect = false
    SetNuiFocus(false, false)
    ClearFocus()
    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(cam, false)
    SetEntityAlpha(PlayerPedId(), 255, false)
    cam = nil
    dialog = {}
    cb('ok')
end)

RegisterNUICallback('getConfig', function(_, cb)
    cb({
        primaryColor = Config.Color.primaryColor,
        secondaryColor = Config.Color.secondaryColor
    })
end)

RegisterNetEvent('rep-talkNPC2:client:close', function()
    SendReactMessage('close')
end)

RegisterNUICallback('click', function(_data, cb) -- truyền xuống data.value là id của elementss
    if dialog[_data + 1].shouldClose then
        SendReactMessage('close')
    end
    dialog[_data + 1].action()
    cb('ok')
end)

exports('CreateNPC', function(...)
    return CreateNPC(...)
end)

exports('changeDialog', function(...)
    changeDialog(...)
end)

exports('updateMessage', function(...)
    updateMessage(...)
end)

CreateThread(function()
    while true do
        if currentNPC and interect == true then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            if #(pos - vector3(currentNPC.coords.x,currentNPC.coords.y, currentNPC.coords.z)) > 5 then
                SetNuiFocus(false, false)
                ClearFocus()
                RenderScriptCams(false, true, 1000, true, false)
                DestroyCam(cam, false)
                SetEntityAlpha(PlayerPedId(), 255, false)
                cam = nil
                currentNPC = nil
                interect = false
                SendReactMessage('close')
            end
        end
        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(_resource)
    for k, v in pairs(NPC) do
        if v.resource == _resource then
            if v.prompt then v.prompt:Destroy() end
            if DoesEntityExist(k) then
                SetEntityAsMissionEntity(k, true, true)
                DeleteEntity(k)
            end
            NPC[k] = nil
        end
    end
end)
