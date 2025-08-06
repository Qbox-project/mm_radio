---@type number
Shared.MaxFrequency = 500.00 -- Max Limit of Radio Channel

---@class Jammer
---@field state boolean
---@field model string
---@field permission string[]
---@field default table
---@field range table

---@type Jammer
Shared.Jammer = {
    state = false, -- to use jammer system or not 
    model = 'sm_prop_smug_jammer', -- prop to spawn for jammer
    permission = {"police"}, -- permission how can setup jammer (job/gang)
    default = {}, -- default jammer setup location 
    range = {
        min = 10.0,
        max = 100.0,
        step = 5.0,
        default = 30.0
    }
}

---@type string[]
Shared.RadioItem = {
    'radio'
}

---@class Battery
---@field state boolean
---@field consume number
---@field depletionTime number

---@type Battery
Shared.Battery = {
    state = false, -- to use battery system or not
    consume = 1, -- battery consume rate
    depletionTime = 1, -- in minute, every 1 minute battery will decrease by consume value
}

---@type [string]: string
Shared.RadioNames = {
    ["1"] = "MRPD CH#1", -- channel value 1
    ["1.%"] = "MRPD CH#1", -- channel value 1.%%%% string formatter
    ["2"] = "MRPD CH#2",
    ["2.%"] = "MRPD CH#2",
    ["3"] = "MRPD CH#3",
    ["3.%"] = "MRPD CH#3",
    ["4"] = "MRPD CH#4",
    ["4.%"] = "MRPD CH#4",
    ["5"] = "MRPD CH#5",
    ["5.%"] = "MRPD CH#5",
    ["6"] = "MRPD CH#6",
    ["6.%"] = "MRPD CH#6",
    ["7"] = "MRPD CH#7",
    ["7.%"] = "MRPD CH#7",
    ["8"] = "MRPD CH#8",
    ["8.%"] = "MRPD CH#8",
    ["9"] = "MRPD CH#9",
    ["9.%"] = "MRPD CH#9",
    ["10"] = "MRPD CH#10",
    ["10.%"] = "MRPD CH#10",
    ["420"] = "Ballas CH#1",
    ["420.%"] = "Ballas CH#1",
    ["421"] = "LostMC CH#1",
    ["421.%"] = "LostMC CH#1",
    ["422"] = "Vagos CH#1",
    ["422.%"] = "Vagos CH#1",
}

Shared.RestrictedChannels = {
    [1] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [2] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [3] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [4] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [5] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [6] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [7] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [8] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [9] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [10] = { -- channel id
        type = 'job', -- job/gang
        name = {"police", "ambulance"}
    },
    [420] = { -- channel id
        type = 'gang', -- job/gang
        name = {"ballas"}
    },
    [421] = { -- channel id
        type = 'gang', -- job/gang
        name = {"lostmc"}
    },
    [422] = {
        type = 'gang', -- job/gang
        name = {"vagos"}
    },
}

Shared.UseRanges = true 

Shared.DefaultRadioFilter = {
    effect = {
        { name = "freq_low", value = 300.0 },
        { name = "freq_hi", value = 5000.0 },
        { name = "rm_mod_freq", value = 400.0 },
        { name = "rm_mix", value = 0.1 },
        { name = "fudge", value = 2.0 },
        { name = "o_freq_lo", value = 300.0 },
        { name = "o_freq_hi", value = 5000.0 },
    },
    volume = {
        frontLeftVolume = 0.25,
        frontRightVolume = 1.0,
        rearLeftVolume = 0.0,
        rearRightVolume = 0.0,
        channel5Volume = 1.0,
        channel6Volume = 1.0
    }
}

Shared.Ranges = {
    {
        ranges = { min = 900.0, max = 1400.0 },
        effect = {
            { name = "freq_low", value = 300.0 },
            { name = "freq_hi", value = 5000.0 },
            { name = "rm_mod_freq", value = 300.0 },
            { name = "rm_mix", value = 0.25 }, -- subtle modulation
            { name = "fudge", value = 5.0 },   -- light distortion
            { name = "o_freq_lo", value = 300.0 },
            { name = "o_freq_hi", value = 5000.0 },
        },
        volume = {
            frontLeftVolume = 0.25,
            frontRightVolume = 0.8,
            rearLeftVolume = 0.0,
            rearRightVolume = 0.0,
            channel5Volume = 0.9,
            channel6Volume = 0.9
        }
    },
    {
        ranges = { min = 1400.0, max = 1900.0 },
        effect = {
            { name = "freq_low", value = 250.0 },
            { name = "freq_hi", value = 4800.0 },
            { name = "rm_mod_freq", value = 300.0 },
            { name = "rm_mix", value = 0.4 },
            { name = "fudge", value = 10.0 },
            { name = "o_freq_lo", value = 300.0 },
            { name = "o_freq_hi", value = 5000.0 },
        },
        volume = {
            frontLeftVolume = 0.2,
            frontRightVolume = 0.6,
            rearLeftVolume = 0.0,
            rearRightVolume = 0.0,
            channel5Volume = 0.7,
            channel6Volume = 0.7
        }
    },
    {
        ranges = { min = 1900.0, max = 2500.0 },
        effect = {
            { name = "freq_low", value = 200.0 },
            { name = "freq_hi", value = 4000.0 },
            { name = "rm_mod_freq", value = 350.0 },
            { name = "rm_mix", value = 0.65 },
            { name = "fudge", value = 18.0 },
            { name = "o_freq_lo", value = 300.0 },
            { name = "o_freq_hi", value = 5000.0 },
        },
        volume = {
            frontLeftVolume = 0.15,
            frontRightVolume = 0.4,
            rearLeftVolume = 0.0,
            rearRightVolume = 0.0,
            channel5Volume = 0.6,
            channel6Volume = 0.6
        }
    },
    {
        ranges = { min = 2500.0, max = 2700.0 },
        effect = {
            { name = "freq_low", value = 150.0 },
            { name = "freq_hi", value = 3500.0 },
            { name = "rm_mod_freq", value = 400.0 },
            { name = "rm_mix", value = 0.85 },
            { name = "fudge", value = 30.0 },
            { name = "o_freq_lo", value = 300.0 },
            { name = "o_freq_hi", value = 5000.0 },
        },
        volume = {
            frontLeftVolume = 0.05,
            frontRightVolume = 0.1,
            rearLeftVolume = 0.0,
            rearRightVolume = 0.0,
            channel5Volume = 0.3,
            channel6Volume = 0.3
        }
    },
    {
        ranges = { min = 2700.0, max = 9999.0 },
        mute = true,
        effect = {}, -- no need
        volume = {}
    }
}


lib.locale()