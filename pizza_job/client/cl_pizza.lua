local ESX = exports["es_extended"]:getSharedObject()

local onDuty = false
local pizzaPed = nil
local pizzaVehicle = nil
local isDelivering = false
local currentDeliveryIndex = 0
local currentBlip = nil
local pizzasLeft = 0
local savedOutfit = {}
local prop_pizza = nil
local hasPizza = false

local function ClearBlips()
    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end
    ClearGpsPlayerWaypoint()
end

local function SetDeliveryWaypoint(index)
    ClearBlips()
    local pt = Config.DeliveryPoints[index]
    currentBlip = AddBlipForCoord(pt.x, pt.y, pt.z)
    SetBlipSprite(currentBlip, 1)
    SetBlipColour(currentBlip, 5)
    SetBlipRoute(currentBlip, true)
    SetBlipRouteColour(currentBlip, 5)
    
    ESX.ShowNotification("Direction " .. pt.name, "info", 5000)
end

local function SaveCurrentOutfit()
    local ped = PlayerPedId()
    savedOutfit = {}
    
    -- Sauvegarder tous les composants de vêtements
    for i = 0, 11 do
        savedOutfit[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i)
        }
    end
    
    -- Sauvegarder les props (accessoires)
    for i = 0, 9 do
        local drawableVariation = GetPedPropIndex(ped, i)
        if drawableVariation >= 0 then
            savedOutfit['prop_' .. i] = {
                drawable = drawableVariation,
                texture = GetPedPropTextureIndex(ped, i)
            }
        end
    end
end

local function ApplyPizzaOutfit()
    local ped = PlayerPedId()
    local gender = 'Male'
    if ESX.PlayerData and ESX.PlayerData.sex then
        gender = ESX.PlayerData.sex == 'f' and 'Female' or 'Male'
    end
    local outfit = Config.Outfit[gender]
    if not outfit then return end

    SetPedComponentVariation(ped, 4, outfit.pants_1 or 0, outfit.pants_2 or 0, 0)
    SetPedComponentVariation(ped, 8, outfit.tshirt_1 or 0, outfit.tshirt_2 or 0, 0)
    SetPedComponentVariation(ped, 11, outfit.torso_1 or 0, outfit.torso_2 or 0, 0)
    SetPedComponentVariation(ped, 6, outfit.shoes_1 or 0, outfit.shoes_2 or 0, 0)
    SetPedComponentVariation(ped, 3, outfit.arms_1 or 0, outfit.arms_2 or 0, 0)
    SetPedComponentVariation(ped, 10, outfit.decals_1 or 0, outfit.decals_2 or 0, 0)

    local helmetDrawable = outfit.helmet_1 or 0
    local hatDrawable = outfit.hat_1 or 0
    if helmetDrawable > 0 then
        local helmetTexture = outfit.helmet_2 or 0
        SetPedPropIndex(ped, 0, helmetDrawable, helmetTexture, true)
    elseif hatDrawable > 0 then
        local hatTexture = outfit.hat_2 or 0
        SetPedPropIndex(ped, 0, hatDrawable, hatTexture, true)
    else
        ClearPedProp(ped, 0)
    end
end

local function RestoreOutfit()
    local ped = PlayerPedId()
    
    for i = 0, 11 do
        if savedOutfit[i] then
            SetPedComponentVariation(ped, i, savedOutfit[i].drawable, savedOutfit[i].texture, 0)
        end
    end
    
    for i = 0, 9 do
        if savedOutfit['prop_' .. i] then
            SetPedPropIndex(ped, i, savedOutfit['prop_' .. i].drawable, savedOutfit['prop_' .. i].texture, true)
        else
            ClearPedProp(ped, i)
        end
    end
    
    savedOutfit = {}
end

local function SpawnPizzaVehicle()
    local model = Config.Job.vehicleModel
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local vPos = Config.Pizzeria.vehicle
    pizzaVehicle = CreateVehicle(model, vPos.x, vPos.y, vPos.z, vPos.w, true, false)
    SetEntityAsMissionEntity(pizzaVehicle, true, true)
    SetVehicleNumberPlateText(pizzaVehicle, Config.Job.vehiclePlate)
    SetPedIntoVehicle(PlayerPedId(), pizzaVehicle, -1)
    SetModelAsNoLongerNeeded(model)
end

local function DeletePizzaVehicle()
    if pizzaVehicle and DoesEntityExist(pizzaVehicle) then
        SetEntityAsMissionEntity(pizzaVehicle, true, true)
        DeleteVehicle(pizzaVehicle)
        pizzaVehicle = nil
    end
end

local function EndDeliveries()
    onDuty = false
    isDelivering = false
    RestoreOutfit()
    
    if prop_pizza then
        DeleteEntity(prop_pizza)
        prop_pizza = nil
    end
    hasPizza = false
    ClearPedTasks(PlayerPedId())

    ClearBlips()
    DeletePizzaVehicle()
    -- hasDelivered: true si au moins une pizza a été livrée
    TriggerServerEvent('rep-pizzajob:endJob', pizzasLeft < Config.Job.maxPizzas)
    pizzasLeft = 0
    exports['rep-talkNPC2']:updateMessage("Travail terminé ! Merci pour ton aide.")
end

local function AttachPizzaBox()
    local ped = PlayerPedId()
    local model = `prop_pizza_box_02`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    
    prop_pizza = CreateObject(model, 0, 0, 0, true, true, true)
    -- Precision offsets fromanimations/props.lua (carrypizza emote)
    AttachEntityToEntity(prop_pizza, ped, GetPedBoneIndex(ped, 28422), 0.01, -0.1, -0.159, 20.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do Wait(1) end
    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    hasPizza = true
end

local function DetachPizzaBox()
    if prop_pizza then
        DeleteEntity(prop_pizza)
        prop_pizza = nil
    end
    ClearPedTasks(PlayerPedId())
    hasPizza = false
end

local function NextDelivery()
    if pizzasLeft <= 0 then
        -- Return to pizzeria
        isDelivering = false
        ClearBlips()
        
        local pPos = Config.Pizzeria.coords
        currentBlip = AddBlipForCoord(pPos.x, pPos.y, pPos.z)
        SetBlipSprite(currentBlip, 1)
        SetBlipColour(currentBlip, 2)
        SetBlipRoute(currentBlip, true)
        SetBlipRouteColour(currentBlip, 2)
        ESX.ShowNotification("Plus de pizzas ! Retournez à la pizzeria.", "warning", 5000)
        return
    end

    -- Pick new random spot
    currentDeliveryIndex = math.random(1, #Config.DeliveryPoints)
    isDelivering = true
    SetDeliveryWaypoint(currentDeliveryIndex)
end

-- Persistent Delivery Interaction Thread
CreateThread(function()
    while true do
        local sleep = 1000
        if isDelivering and currentDeliveryIndex > 0 then
            local pt = Config.DeliveryPoints[currentDeliveryIndex]
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - vector3(pt.x, pt.y, pt.z))
            local m = Config.Marker

            if dist < m.drawDistance then
                sleep = 0
                -- Draw Bobbing Marker
                DrawMarker(m.type, pt.x, pt.y, pt.z + 1.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, m.size.x, m.size.y, m.size.z, m.color.r, m.color.g, m.color.b, m.color.a, m.bobUpAndDown, m.faceCamera, 2, m.rotate, nil, nil, false)
                
                if dist < 2.0 then
                    if hasPizza then
                        if not IsPedInAnyVehicle(ped, false) then
                            ESX.ShowHelpNotification("~INPUT_CONTEXT~ livré la ~o~pizza.")
                            if IsControlJustReleased(0, 38) then -- E (INPUT_CONTEXT)
                                DetachPizzaBox()
                                local distFromStart = #(Config.Pizzeria.coords - vector3(pt.x, pt.y, pt.z))
                                local payout = math.floor(distFromStart * Config.Job.payoutCoefficient)
                                
                                pizzasLeft = pizzasLeft - 1
                                TriggerServerEvent('rep-pizzajob:payoutDelivery', payout)
                                ESX.ShowNotification("Il vous reste " .. pizzasLeft .. " pizzas", "success", 5000)
                                
                                Wait(1000)
                                NextDelivery()
                            end
                        else
                            ESX.ShowHelpNotification("~r~Descendez de votre véhicule pour livrer.")
                        end
                    else
                        ESX.ShowHelpNotification("~r~Allez chercher la pizza au scooter.")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Interaction with vehicle (Forced to Target)
local function SetupVehicleInteraction()
    exports.ox_target:addLocalEntity(pizzaVehicle, {
        {
            name = 'pizza_take',
            icon = 'fa-solid fa-box',
            label = 'Prendre une pizza',
            canInteract = function()
                local canTake = onDuty and not hasPizza and pizzasLeft > 0 and isDelivering and not IsPedInAnyVehicle(PlayerPedId(), false)
                if not canTake then return false end
                
                -- Ensure in delivery zone
                local pt = Config. DeliveryPoints[currentDeliveryIndex]
                local dist = #(GetEntityCoords(PlayerPedId()) - vector3(pt.x, pt.y, pt.z))
                return dist < 30.0 -- Adjust distance as needed
            end,
            onSelect = function()
                AttachPizzaBox()
            end
        },
        {
            name = 'pizza_put',
            icon = 'fa-solid fa-arrow-down-long',
            label = 'Ranger la pizza',
            canInteract = function()
                return onDuty and hasPizza and not IsPedInAnyVehicle(PlayerPedId(), false)
            end,
            onSelect = function()
                DetachPizzaBox()
            end
        }
    })
end

local function StartDeliveries()
    onDuty = true
    SaveCurrentOutfit()
    ApplyPizzaOutfit()
    SpawnPizzaVehicle()
    SetupVehicleInteraction()
    pizzasLeft = Config.Job.maxPizzas
    TriggerServerEvent('rep-pizzajob:givePizzas', pizzasLeft)
    exports['rep-talkNPC2']:updateMessage("Super ! En route. Récupère une pizza dans ton coffre et livre-la.")
    TriggerEvent('rep-talkNPC2:client:close')
    Wait(1000)
    NextDelivery()
end


CreateThread(function()
    local p = Config.Pizzeria
    local b = p.blip
    
    -- Permanent Pizzeria Blip
    local pizzeriaBlip = AddBlipForCoord(p.coords.x, p.coords.y, p.coords.z)
    SetBlipSprite(pizzeriaBlip, b.sprite)
    SetBlipColour(pizzeriaBlip, b.color)
    SetBlipScale(pizzeriaBlip, b.scale)
    SetBlipAsShortRange(pizzeriaBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(b.label)
    EndTextCommandSetBlipName(pizzeriaBlip)

    local l = p.luigi
    
    pizzaPed = exports['rep-talkNPC2']:CreateNPC({
        npc = l.model,
        coords = l.coords,
        name = l.name,
        tag = l.tag,
        color = l.color,
        startMSG = l.startMSG,
        animName = l.animDict,
        animDist = l.animName,
        onInteract = function()
            PlayPedAmbientSpeechNative(pizzaPed, l.interactionSpeech, "SPEECH_PARAMS_FORCE")
        end
    }, {
        [1] = {
            label = "Commencer les livraisons",
            shouldClose = false,
            canInteract = function()
                return not onDuty
            end,
            action = function()
                StartDeliveries()
            end
        },

        [2] = {
            label = "Terminer les livraisons",
            shouldClose = false,
            canInteract = function()
                return onDuty
            end,
            action = function()
                EndDeliveries()
            end
        },
        [3] = {
            label = "Partir (Annulé)",
            color = "red",
            shouldClose = true,
            action = function()
            end
        }
    })
    
    -- Cleanup if player dies while on duty
    while true do
        Wait(1000)
        if onDuty and IsEntityDead(PlayerPedId()) then
            EndDeliveries()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if pizzaPed and DoesEntityExist(pizzaPed) then
            SetEntityAsMissionEntity(pizzaPed, true, true)
            DeleteEntity(pizzaPed)
        end
        DeletePizzaVehicle()
        ClearBlips()
    end
end)
