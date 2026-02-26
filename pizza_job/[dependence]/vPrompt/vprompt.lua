local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 19, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["UP"] = 27, ["DOWN"] = 173
}

local function mergeTables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                mergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

vPrompt = {}
vPrompt.__index = vPrompt

function vPrompt:Create(options)
    local obj = {}
    setmetatable(obj, vPrompt)
    obj:_Init(options)
    return obj
end

function vPrompt:_Init(cfg)
    assert(Keys[cfg.key] ~= nil, string.format('^1Invalid key: %s', cfg.key))

    -- CONFIGURATION PAR DÉFAUT (Dimensions réduites appliquées ici)
    local defaultConfig = {
        debug = false,
        font = 0,
        scale = 0.3,                                          -- Taille du texte
        origin = vector2(0, 0),
        offset = vector3(0, 0, 0),
        margin = 0.005,                                       -- Marge réduite
        padding = 0.002,                                      -- Padding réduit
        textOffset = 0.006,                                   -- Centrage vertical
        buttonSize = 0.012,                                   -- Carré de touche réduit
        backgroundColor = { r = 0, g = 0, b = 0, a = 100 },
        labelColor = { r = 255, g = 255, b = 255, a = 255 },
        buttonColor = { r = 0, g = 96, b = 247, a = 255 },    -- Bleu personnalisé
        keyColor = { r = 255, g = 255, b = 255, a = 255 },
        drawDistance = 4.0,
        interactDistance = 2.0,
        canDraw = function() return true end,
        canInteract = function() return true end,
        drawMarker = false
    }

    local defaultMarker = {
        drawDistance = 20.0,
        type = 1,
        dirX = 0.0, dirY = 0.0, dirZ = 0.0, 
        rotX = 0.0, rotY = 0.0, rotZ = 0.0, 
        scaleX = 1.0, scaleY = 1.0, scaleZ = 1.0, 
        color = { r = 255, g = 255, b = 255, a = 150 },
        bobUpAndDown = false, 
        faceCamera = false, 
        rotate = false,
        textureDict = nil,
        textureName = nil,
        drawOnEnts = false
    }

    self.cfg = mergeTables(defaultConfig, cfg)   
    self.cfg.key = Keys[cfg.key]
    self.cfg.keyLabel = tostring(cfg.key)
    self.cfg.label = tostring(cfg.label)
    self.cfg.callbacks = {}

    if self.cfg.entity then
        assert(DoesEntityExist(self.cfg.entity), '^1Invalid entity passed to "entity" option')
    elseif self.cfg.bone then
        assert(DoesEntityExist(self.cfg.bone.entity), '^1Invalid entity passed to "bone.entity" option')
        self.cfg.boneEntity = self.cfg.bone.entity
        self.cfg.boneIndex = GetEntityBoneIndexByName(self.cfg.bone.entity, self.cfg.bone.name)
    elseif self.cfg.coords then
        assert(type(self.cfg.coords) == 'vector3', '^1Invalid vector3 value passed to "coords" option')
        self.cfg.coords = self.cfg.coords + self.cfg.offset    
    end

    if self.cfg.drawMarker ~= false then
        assert(type(self.cfg.drawMarker) == 'table', '^1Option "drawMarker" must be table of options')
        self.cfg.marker = mergeTables(defaultMarker, self.cfg.drawMarker)   
    end

    self:_CreateThread()
    
    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then
            self:Destroy()
        end
    end)    
end

function vPrompt:Update()
    self:_GetDimensions()
    self:_SetButton()
    self:_SetPadding()
    self:_SetBackground()
end

function vPrompt:SetKey(key)
    assert(Keys[key] ~= nil, '^1Invalid key:'.. key)
    if tostring(key) ~= self.cfg.keyLabel then
        self.cfg.key        = Keys[key]
        self.cfg.keyLabel   = tostring(key)
    end
end

function vPrompt:SetLabel(label)
    if label ~= self.cfg.label then
        self.cfg.label = label
        self:Update()
    end
end

function vPrompt:SetBackgroundColor(r, g, b, a)
    self.cfg.backgroundColor = {r = r, g = g, b = b, a = a}
end

function vPrompt:SetLabelColor(r, g, b, a)
    self.cfg.labelColor = {r = r, g = g, b = b, a = a}
end

function vPrompt:SetKeyColor(r, g, b, a)
    self.cfg.keyColor = {r = r, g = g, b = b, a = a}
end

function vPrompt:SetButtonColor(r, g, b, a)
    self.cfg.buttonColor = {r = r, g = g, b = b, a = a}
end

function vPrompt:SetCoords(coords)
    self.cfg.coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
end

function vPrompt:Destroy()
    self.stop = true
    self.cfg.callbacks = {}
end

function vPrompt:On(event, cb)
    assert(type(event) == 'string', string.format("^1Invalid type for param: 'event' | Expected 'string', got %s ", type(event)))
    assert(self.cfg.callbacks[event] == nil, string.format("^1Event '%s' already registered", event))
    self.cfg.callbacks[event] = cb
end

-- PRIVATE METHODS
function vPrompt:_GetDimensions()
    local sw, sh = GetActiveScreenResolution()
    self.keyTextWidth = self:_GetTextWidth(self.cfg.keyLabel) 
    self.labelTextWidth = self:_GetTextWidth(self.cfg.label) 
    self.textHeight = GetRenderedCharacterHeight(self.cfg.scale, self.cfg.font)
    self.sw, self.sh = sw, sh
end

function vPrompt:_SetButton()
    self.button = {
        w = (math.max(self.cfg.buttonSize, self.keyTextWidth) * self.sw) / self.sw,
        h = (self.cfg.buttonSize * self.sw) / self.sh,
        bc = self.cfg.buttonColor,
        fc = self.cfg.keyColor          
    }
    self.fx = { w = self.button.w, h = self.button.h, a = 255 }
end

function vPrompt:_SetPadding()
    local padding = self.cfg.padding
    self.boxPadding = {
        x = (padding * self.sw) / self.sw,
        y = (padding * self.sw) / self.sh
    }
end

function vPrompt:_SetBackground()
    self.minWidth = self.button.w + (self.boxPadding.x * 2)
    self.maxWidth = self.labelTextWidth + self.button.w + (self.boxPadding.x * 3) + (self.cfg.margin * 2)
    self.background = {
        w = self.maxWidth,
        h = self.button.h + (self.boxPadding.y * 2),
        bc = self.cfg.backgroundColor,
        fc = self.cfg.labelColor    
    }
    self.button.x = self.cfg.origin.x - (self.background.w / 2) + (self.button.w / 2) + self.boxPadding.x
    self.button.y = self.cfg.origin.y - (self.background.h / 2) + (self.button.h / 2) + self.boxPadding.y 
    self.button.text = {
        x = self.button.x,
        y = self.button.y - self.textHeight + self.cfg.textOffset
    }
    self.background.text = {
        x = self.button.x + (self.button.w / 2) + self.cfg.margin + self.boxPadding.x,
        y = self.button.y - self.textHeight + self.cfg.textOffset
    }
    if self.cfg.drawDistance > self.cfg.interactDistance then self.background.w = self.minWidth end
end

function vPrompt:_Draw()
    local bg, btn = self.background, self.button
    if self.canInteract then
        if bg.w < self.maxWidth then bg.w = bg.w + 0.008 end
        bg.fc.a = 255
    else
        if bg.w > self.minWidth then bg.w = bg.w - 0.008 else bg.w = self.minWidth end
        bg.fc.a = 0
    end
    btn.x = self.cfg.origin.x - (bg.w / 2) + (btn.w / 2) + self.boxPadding.x
    btn.text.x = btn.x
    self:_RenderElement(self.cfg.label, bg)
    self:_RenderElement(self.cfg.keyLabel, btn, true)
    if self.pressed then
        self.fx.w = self.fx.w + (0.0005 * self.sw) / self.sw
        self.fx.h = self.fx.h + (0.0005 * self.sw) / self.sh
        self.fx.a = self.fx.a - 18
        SetDrawOrigin(self.cfg.coords.x, self.cfg.coords.y, self.cfg.coords.z, 0)
        DrawRect(btn.x, btn.y, self.fx.w, self.fx.h, btn.bc.r, btn.bc.g, btn.bc.b, self.fx.a)
        ClearDrawOrigin()  
        if self.fx.a <= 0 then self.pressed = false; self.fx = { w = btn.w, h = btn.h, a = 255 } end
    end
end

function vPrompt:_CreateThread()
    Citizen.CreateThread(function()
        self:Update()
        while true do
            local letSleep = true
            local pcoords = GetEntityCoords(PlayerPedId())
            if self.cfg.entity then 
                self.cfg.coords = GetEntityCoords(self.cfg.entity) + self.cfg.offset
            elseif self.cfg.boneEntity then 
                self.cfg.coords = GetWorldPositionOfEntityBone(self.cfg.boneEntity, self.cfg.boneIndex) + self.cfg.offset
            end
            local dist = #(self.cfg.coords - pcoords)
            if dist < self.cfg.drawDistance then
                if self.cfg.canDraw() then
                    letSleep = false
                    self:_Draw()
                    if not self.visible then 
                        self.visible = true
                        if self.cfg.callbacks.show then self.cfg.callbacks.show() end
                    end
                    if dist < self.cfg.interactDistance then
                        if not self.InInteractionArea then 
                            self.InInteractionArea = true
                            if self.cfg.callbacks.enterInteractZone then self.cfg.callbacks.enterInteractZone() end
                        end
                        self.canInteract = true
                        if IsControlJustPressed(0, self.cfg.key) then
                            self.pressed = true
                            if self.cfg.canInteract() and self.cfg.callbacks.interact then
                                self.cfg.callbacks.interact(dist, pcoords)
                            end
                        end
                    else
                        self.canInteract = false
                        if self.InInteractionArea then 
                            self.InInteractionArea = false
                            if self.cfg.callbacks.exitInteractZone then self.cfg.callbacks.exitInteractZone() end
                        end
                    end
                end
            else
                if self.visible then 
                    self.visible = false
                    if self.cfg.callbacks.hide then self.cfg.callbacks.hide() end
                end
            end
            if self.cfg.marker or self.cfg.debug then
                letSleep = false
                local _, groundZ = GetGroundZFor_3dCoord(self.cfg.coords.x, self.cfg.coords.y, self.cfg.coords.z, false)
                if self.cfg.marker and dist < self.cfg.marker.drawDistance then
                    local m = self.cfg.marker
                    DrawMarker(m.type, self.cfg.coords.x, self.cfg.coords.y, groundZ, m.dirX, m.dirY, m.dirZ, m.rotX, m.rotY, m.rotZ, m.scaleX, m.scaleY, m.scaleZ, m.color.r, m.color.g, m.color.b, m.color.a, m.bobUpAndDown, m.faceCamera, 2, m.rotate, m.textureDict, m.textureName, m.drawOnEnts)
                end
            end
            if letSleep then Citizen.Wait(1000) end
            Citizen.Wait(0)
            if self.stop then return end
        end
    end)
end

function vPrompt:_GetTextWidth(text)
    BeginTextCommandGetWidth("STRING")
    SetTextScale(self.cfg.scale, self.cfg.scale)
    SetTextFont(self.cfg.font)
    AddTextComponentString(text)
    return EndTextCommandGetWidth(1)    
end

function vPrompt:_RenderElement(text, box, centered)
    SetTextScale(self.cfg.scale, self.cfg.scale)
    SetTextFont(self.cfg.font)
    SetTextColour(box.fc.r, box.fc.g, box.fc.b, box.fc.a)
    SetTextEntry("STRING")
    SetTextCentre(centered ~= nil)
    AddTextComponentString(text)
    SetDrawOrigin(self.cfg.coords.x, self.cfg.coords.y, self.cfg.coords.z, 0)
    EndTextCommandDisplayText(box.text.x, box.text.y)
    DrawRect(box.x, box.y, box.w, box.h, box.bc.r, box.bc.g, box.bc.b, box.bc.a)
    ClearDrawOrigin()
end

-- Exportation pour utilisation externe
exports('CreatePrompt', function(options)
    return vPrompt:Create(options)
end)