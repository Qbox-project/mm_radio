local channels = {}
local jammer = {}
local batteryData = {}
local currentChannel = {}
local batteryCooldown = {}
local radioCooldown = {}
local spawnedDefaultJammer = false
local nextJammerId = 0

local function isFiniteNumber(value)
    return type(value) == 'number' and value == value and value > -math.huge and value < math.huge
end

local function getPlayerRadioIds(source)
    local radioIds = {}

    for i = 1, #Shared.RadioItem do
        local slots = exports.ox_inventory:GetSlotsWithItem(source, Shared.RadioItem[i])
        for _, item in pairs(slots or {}) do
            local radioId = item.metadata?.radioId
            if radioId then radioIds[radioId] = true end
        end
    end

    return radioIds
end

local function hasRadio(source)
    for i = 1, #Shared.RadioItem do
        local slot = exports.ox_inventory:GetSlotIdWithItem(source, Shared.RadioItem[i])
        if slot then return true end
    end

    return false
end

local function removePlayerFromRadioChannel(source)
    local channel = currentChannel[source]
    if not channel or not channels[channel] then return end

    channels[channel][tostring(source)] = nil
    currentChannel[source] = nil
    TriggerClientEvent('mm_radio:client:radioListUpdate', -1, channels[channel], channel)
    if not next(channels[channel]) then channels[channel] = nil end
end

local function checkCooldown(cooldowns, source, duration)
    local time = os.time()
    if cooldowns[source] and cooldowns[source] > time then return false end

    cooldowns[source] = time + duration
    return true
end

local function hasChannelPermission(player, channel)
    local restriction = Shared.RestrictedChannels[channel]
    if not restriction then return true end

    local group = player.PlayerData[restriction.type]
    return group and lib.table.contains(restriction.name, group.name)
end

local function hasJammerPermission(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player or not Shared.Jammer.permission then return false end

    local job = player.PlayerData.job
    local gang = player.PlayerData.gang
    return job and lib.table.contains(Shared.Jammer.permission, job.name)
        or gang and lib.table.contains(Shared.Jammer.permission, gang.name)
end

local function sanitizeAllowedChannels(allowedChannels)
    local sanitized = {}
    local seen = {}
    if type(allowedChannels) ~= 'table' then return sanitized end

    for i = 1, math.min(#allowedChannels, 32) do
        local channel = allowedChannels[i]
        if isFiniteNumber(channel) and channel > 0 and channel <= Shared.MaxFrequency and not seen[channel] then
            sanitized[#sanitized + 1] = channel
            seen[channel] = true
        end
    end

    return sanitized
end

local function getJammer(id)
    for i = 1, #jammer do
        if jammer[i].id == id then return jammer[i], i end
    end
end

local function isNearJammer(source, entity)
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end

    return #(GetEntityCoords(ped) - vec3(entity.coords.x, entity.coords.y, entity.coords.z)) <= 3.0
end

local function getNextJammerId()
    local id
    repeat
        nextJammerId += 1
        id = ('placed:%d'):format(nextJammerId)
    until not getJammer(id)

    return id
end

local function createJammer(data, source)
    CreateThread(function()
        local entity = CreateObject(joaat(Shared.Jammer.model), data.coords.x, data.coords.y, data.coords.z, true, true, false)
        local attempts = 0
        while not DoesEntityExist(entity) and attempts < 100 do
            attempts += 1
            Wait(50)
        end

        if not DoesEntityExist(entity) then
            if source then exports.ox_inventory:AddItem(source, 'jammer', 1) end
            return
        end

        SetEntityHeading(entity, data.coords.w)
        local netobj = NetworkGetNetworkIdFromEntity(entity)
        local jammerData = {
            enable = true,
            entity = entity,
            id = data.id,
            coords = data.coords,
            range = data.range,
            allowedChannels = data.allowedChannels,
            canRemove = data.canRemove,
            canDamage = data.canDamage
        }

        jammer[#jammer + 1] = jammerData
        TriggerClientEvent('mm_radio:client:syncobject', -1, {
            enable = jammerData.enable,
            object = netobj,
            coords = jammerData.coords,
            id = jammerData.id,
            range = jammerData.range,
            allowedChannels = jammerData.allowedChannels,
            canRemove = jammerData.canRemove,
            canDamage = jammerData.canDamage
        })
    end)
end

RegisterNetEvent('mm_radio:server:consumeBattery', function()
    if not Shared.Battery.state then return end
    if not checkCooldown(batteryCooldown, source, math.max(math.floor(Shared.Battery.depletionTime * 60), 1)) then return end

    local radioIds = getPlayerRadioIds(source)
    for id in pairs(radioIds) do
        if not batteryData[id] then batteryData[id] = 100 end
        local battery = batteryData[id] - Shared.Battery.consume
        batteryData[id] = math.max(battery, 0)
        if batteryData[id] == 0 then
            TriggerClientEvent('mm_radio:client:nocharge', source)
        end
    end
end)

RegisterNetEvent('mm_radio:server:rechargeBattery', function()
    if not Shared.Battery.state then return end

    local src = source
    for i=1, #Shared.RadioItem do
        local item = exports.ox_inventory:GetSlotWithItem(src, Shared.RadioItem[i])
        if item then
            local id = item.metadata?.radioId or false
            if not id then return end
            if not exports.ox_inventory:RemoveItem(src, 'radiocell', 1) then return end
            batteryData[id] = 100
            break
        end
    end
end)

RegisterNetEvent('mm_radio:server:spawnobject', function(data)
    local src = source
    if type(data) ~= 'table' or not hasJammerPermission(src) then return end

    local coords = data.coords
    local coordsType = type(coords)
    if coordsType ~= 'table' and coordsType ~= 'vector4' then return end
    if not isFiniteNumber(coords.x) or not isFiniteNumber(coords.y)
        or not isFiniteNumber(coords.z) or not isFiniteNumber(coords.w) then return end

    local ped = GetPlayerPed(src)
    if ped == 0 or #(GetEntityCoords(ped) - vec3(coords.x, coords.y, coords.z)) > 3.0 then return end
    if not exports.ox_inventory:RemoveItem(src, 'jammer', 1) then return end

    createJammer({
        coords = vec4(coords.x, coords.y, coords.z, coords.w),
        id = getNextJammerId(),
        range = Shared.Jammer.range.default,
        allowedChannels = {},
        canRemove = true,
        canDamage = true
    }, src)
end)

RegisterNetEvent('mm_radio:server:togglejammer', function(id)
    local entity = getJammer(id)
    if not entity or not isNearJammer(source, entity) then return end

    entity.enable = not entity.enable
    TriggerClientEvent('mm_radio:client:togglejammer', -1, id, entity.enable)
end)

RegisterNetEvent('mm_radio:server:removejammer', function(id)
    local src = source
    local entity, index = getJammer(id)
    if not entity or not entity.canRemove or not isNearJammer(src, entity) then return end

    local shouldRefund = GetEntityHealth(entity.entity) > 0
    DeleteEntity(entity.entity)
    TriggerClientEvent('mm_radio:client:removejammer', -1, id)
    table.remove(jammer, index)
    if shouldRefund then exports.ox_inventory:AddItem(src, 'jammer', 1) end
end)

RegisterNetEvent('mm_radio:server:changeJammerRange', function(id, range)
    local entity = getJammer(id)
    if not entity or not isNearJammer(source, entity) or not isFiniteNumber(range) then return end

    entity.range = math.min(math.max(range, Shared.Jammer.range.min), Shared.Jammer.range.max)
    TriggerClientEvent('mm_radio:client:changeJammerRange', -1, id, entity.range)
end)

RegisterNetEvent('mm_radio:server:removeallowedchannel', function(id, allowedChannels)
    local entity = getJammer(id)
    if not entity or not isNearJammer(source, entity) then return end

    entity.allowedChannels = sanitizeAllowedChannels(allowedChannels)
    TriggerClientEvent('mm_radio:client:removeallowedchannel', -1, id, entity.allowedChannels)
end)

RegisterNetEvent('mm_radio:server:addallowedchannel', function(id, allowedChannels)
    local entity = getJammer(id)
    if not entity or not isNearJammer(source, entity) then return end

    entity.allowedChannels = sanitizeAllowedChannels(allowedChannels)
    TriggerClientEvent('mm_radio:client:addallowedchannel', -1, id, entity.allowedChannels)
end)

RegisterNetEvent('mm_radio:server:addToRadioChannel', function(channel)
    local src = source
    if not isFiniteNumber(channel) or channel <= 0 or channel > Shared.MaxFrequency then return end

    local normalizedChannel = math.floor(channel * 100 + 0.5) / 100
    if math.abs(channel - normalizedChannel) > 0.00001 or not checkCooldown(radioCooldown, src, 1) then return end
    channel = normalizedChannel

    local player = exports.qbx_core:GetPlayer(src)
    if not player or not hasRadio(src) or not hasChannelPermission(player, channel) then return end

    removePlayerFromRadioChannel(src)
    if not channels[channel] then
        channels[channel] = {}
    end

    local charinfo = player.PlayerData.charinfo
    channels[channel][tostring(src)] = {
        name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
        isTalking = false
    }
    currentChannel[src] = channel
    TriggerClientEvent('mm_radio:client:radioListUpdate', -1, channels[channel], channel)
end)

RegisterNetEvent('mm_radio:server:removeFromRadioChannel', function()
    removePlayerFromRadioChannel(source)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for i=1, #jammer do
        DeleteEntity(jammer[i].entity)
    end
    jammer = {}
    SaveResourceFile(GetCurrentResourceName(), 'battery.json', json.encode(batteryData), -1)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    batteryData = json.decode(LoadResourceFile(GetCurrentResourceName(), 'battery.json')) or {}
end)

AddEventHandler("playerDropped", function()
    removePlayerFromRadioChannel(source)
    batteryCooldown[source] = nil
    radioCooldown[source] = nil
end)

RegisterNetEvent("mm_radio:server:createdefaultjammer", function()
    if spawnedDefaultJammer then return end
    for i=1, #Shared.Jammer.default do
        local data = Shared.Jammer.default[i]
        createJammer({
            coords = data.coords,
            id = data.id,
            range = math.min(math.max(data.range or Shared.Jammer.range.default, Shared.Jammer.range.min), Shared.Jammer.range.max),
            allowedChannels = sanitizeAllowedChannels(data.allowedChannels),
            canRemove = false,
            canDamage = data.canDamage
        })
    end
    spawnedDefaultJammer = true
end)

local function SetRadioData(src, slot)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local radioId = player.PlayerData.citizenid .. math.random(1000, 9999)
    local name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    exports.ox_inventory:SetMetadata(src, slot, { radioId = radioId, name = name })
    return radioId
end

local function GetSlotWithRadio(source)
    for i=1, #Shared.RadioItem do
        return exports.ox_inventory:GetSlotIdWithItem(source, Shared.RadioItem[i])
    end
end

lib.callback.register('mm_radio:server:getradiodata', function(source, slot)
    if not Shared.Battery.state then return 100, 'PERSONAL' end
    local battery = 100
    local slotid = false
    if not slot then
        slotid = GetSlotWithRadio(source)
    else
        slotid = slot.slot
    end
    local slotData = exports.ox_inventory:GetSlot(source, slotid)
    if slotData and lib.table.contains(Shared.RadioItem, slotData.name) then
        local id = false
        if not slotData.metadata?.radioId then
            id = SetRadioData(source, slotid)
        else
            id = slotData.metadata?.radioId
        end
        battery = id and batteryData[id] or 100
    end
    return battery, id
end)

lib.callback.register('mm_radio:server:getjammer', function()
    return jammer
end)

if Shared.UseCommand then
    if not Shared.Ready then return end
    lib.addCommand('radio', {
        help = 'Open Radio Menu',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:use', source, 100)
    end)
    lib.addCommand('jammer', {
        help = 'Setup Jammer',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:usejammer', source)
    end)
    lib.addCommand('rechargeradio', {
        help = 'Recharge Radio Battery',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:recharge', source)
    end)
end

lib.addCommand('remradiodata', {
    help = 'Remove Radio Data',
    params = {},
}, function(source)
    TriggerClientEvent('mm_radio:client:removedata', source)
end)

lib.versionCheck('Qbox-project/mm_radio')
