Config = {}

-- General System Settings
Config.Debug = false       -- Enable debug prints
Config.CheckInterval = 200 -- How often to check player status (ms)

-- Player Status HUD Configuration
Config.Status = {
    Enabled = true, -- Master toggle for Player HUD

    -- Color Configuration (Hex Codes)
    Colors = {
        Health = '#FF3B30',  -- Red
        Armor = '#007AFF',   -- Blue
        Hunger = '#FF9500',  -- Orange
        Thirst = '#5AC8FA',  -- Sky Blue
        Stress = '#AF52DE',  -- Purple
        Stamina = '#FFCC00', -- Yellow
    },

    -- Visibility Toggles
    Toggles = {
        Stress = true,  -- Show/Hide Stress indicator
        Stamina = true, -- Show/Hide Stamina indicator
    }
}

-- Vehicle HUD Configuration
Config.Vehicle = {
    Enabled = true, -- Master toggle for Vehicle HUD
    UseMPH = false, -- Set to true for MPH, false for KMH

    -- Feature Toggles
    ShowRPM = true,
    ShowFuel = true,
    ShowGear = true,
    ShowSeatbelt = true,
}

-- Info HUD Configuration (Top Right)
Config.Info = {
    Enabled = true, -- Master toggle for Info HUD

    -- Feature Toggles
    ShowTime = true,
    ShowCash = true,
    ShowJob = true,

    -- Format Settings
    TimeFormat = "%H:%M", -- Lua date format string
    CurrencySymbol = "$", -- Currency prefix
}
