local Config = {
    Key = Enum.KeyCode.V  -- Taste zum Aktivieren
}

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TradingCmds = require(ReplicatedStorage.Library.Client.TradingCmds)

-- Speicher für die "Fake" Items, die weiterhin im Trade angezeigt werden sollen
local VisualBugItems = {}

-- Original GetState Funktion zwischenspeichern
local originalGetState = TradingCmds.GetState

-- Hooken der GetState Funktion, um die Items für den anderen Spieler zu manipulieren
TradingCmds.GetState = hookfunction(originalGetState, function(...)
    local state = originalGetState(...)
    for userId, data in pairs(state._items) do
        if VisualBugItems[userId] then
            data["2"] = VisualBugItems[userId]  -- Manipuliert die Items, die der andere Spieler sieht
        end
    end
    return state
end)

-- Funktion, um die Items zu "fixieren" (Fake-Items für den anderen Spieler anzeigen)
local function ActivateVisualBug()
    local state = originalGetState()._items
    for userId, data in pairs(state) do
        if data["2"] then  -- Wir speichern die Items im Slot 2 (für den anderen Spieler)
            VisualBugItems[userId] = data["2"]
        end
    end
    print("🎭 Visual Bug aktiviert – Der andere Spieler sieht die Items weiterhin im Trade.")
end

-- Funktion, um den Visual Bug zurückzusetzen
local function ResetVisualBug()
    VisualBugItems = {}
    print("🔄 Visual Bug deaktiviert.")
end

-- Tastendruck-Event zum Aktivieren/Deaktivieren
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Config.Key and not gpe then
        if next(VisualBugItems) then
            ResetVisualBug()
        else
            ActivateVisualBug()
        end
    end
end)
