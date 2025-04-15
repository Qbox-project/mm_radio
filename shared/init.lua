Shared = {}

---@class Shared
---@field Ready boolean
---@field UseCommand boolean
---@field Debug boolean
---@field Overlay 'default'|'always'|'never'

---@type Shared
Shared = {
    Ready = true,
    UseCommand = true,
    Debug = false,
    Overlay = 'default' -- default, always, never
}

if not LoadResourceFile(GetCurrentResourceName(), 'build/index.html') then
    Shared.Ready = false
    warn('UI has not been built, refer to the readme or download a release build.\n	^3https://github.com/Qbox-project/mm_radio/releases/')
end

if not lib.checkDependency('ox_lib', '3.14.0') then
    Shared.Ready = false
    warn('Missing Update of ox_lib, please update your ox_lib to 3.14.0')
end

lib.locale()