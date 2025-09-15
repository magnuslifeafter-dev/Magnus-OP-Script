-- ====== Setup / Services ======
local tween_service   = game:GetService("TweenService")
local run_service     = game:GetService("RunService")
local stats           = game:GetService("Stats")
local players         = game:GetService("Players")
local marketplace     = game:GetService("MarketplaceService")

-- Local player reference
local local_player = players.LocalPlayer

-- Game info (used in watermark)
local success, info = pcall(function()
    return marketplace:GetProductInfo(game.PlaceId)
end)
if not success then
    info = { Name = "Unknown Game" }
end

-- ====== Script Variables ======
local stud_offset       = 5   -- default Y offset
local tp_walk           = false
local tp_walk_speed     = 5
local inf_jump          = false
local goto_closest      = false
local auto_start        = false
local auto_redo         = false
local kill_aura         = false

-- Placeholders for connections
local velocity_connection = nil
local speed_connection    = nil
local watermark_connection = nil

-- Enemy Placeholder
local current_mob = nil

-- ====== Main Script ======
if game.PlaceId == 94845773826960 then
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "Magnus Script HUB",
        LoadingTitle = "Magnus OP Script",
        LoadingSubtitle = "by Magnus",
        ConfigurationSaving = { 
            Enable = false,
            FolderName = nil,
            FileName = "Magnus Hub"
        },
        KeySystem = false,
        KeySettings = {
            Title = "No Key",
            Subtitle = "Key System",
            Note = "No Key",
            FileName = "No key",
            SaveKey = false,
            GrabKeyFromSite = false,
        }
    })

    -- ===== Tabs =====
    local game_tab    = Window:CreateTab("Game")
    local player_tab  = Window:CreateTab("Player")
    local ui_tab      = Window:CreateTab("UI Settings")

    -- Sections (groups)
    local game_group   = game_tab:CreateSection("Game Settings")
    local player_group = player_tab:CreateSection("Player Settings")
    local menu_group   = ui_tab:CreateSection("Menu")

    -- ===== Example Tween =====
    local hrp = local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local tween = tween_service:Create(
            hrp,
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { CFrame = CFrame.new(Vector3.new(0, stud_offset, 0)) }
        )
        tween:Play()
        tween.Completed:Wait()
    end

    -- Safe mob check
    if velocity_connection then
        velocity_connection:Disconnect()
        velocity_connection = nil
    elseif current_mob then
        local hp = 0
        if typeof(current_mob.GetAttribute) == "function" then
            hp = current_mob:GetAttribute("HP") or 0
        end

        if hp > 0 and local_player and local_player.Character then
            local ok, pivot = pcall(function()
                return current_mob:GetPivot()
            end)
            if ok and pivot then
                local_player.Character:MoveTo(pivot.Position + Vector3.new(0, stud_offset, 0))
            end
        end
    end

    -- ===== Game UI =====
    game_group:AddSlider('stud_offset_y', {
        Text = 'Stud Offset Y:',
        Default = stud_offset,
        Min = -50,
        Max = 50,
        Rounding = 0,
        Compact = false,
        Callback = function(Value) stud_offset = Value end
    })

    -- ===== Player UI =====
    player_group:AddToggle('tp_walk', {
        Text = 'Tp Walk',
        Default = tp_walk,
        Tooltip = 'Goes fast idk',
        Callback = function(Value) tp_walk = Value end
    })
    player_group:AddSlider('tp_walk_speed', {
        Text = 'Tp Walk Speed:',
        Default = tp_walk_speed,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Compact = false,
        Callback = function(Value) tp_walk_speed = Value end
    })
    player_group:AddDivider()
    player_group:AddToggle('inf_jump', {
        Text = 'Inf Jump',
        Default = inf_jump,
        Tooltip = 'Lets you jump forever',
        Callback = function(Value) inf_jump = Value end
    })

    -- ===== Watermark / FPS =====
    local FrameTimer = tick()
    local FrameCounter = 0
    local FPS = 60

    local watermark_display = ui_tab:CreateSection("Watermark"):AddLabel("Loading watermark...")

    watermark_connection = run_service.RenderStepped:Connect(function()
        FrameCounter = FrameCounter + 1
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end

        local text = ("Magnus HUB | %s fps | game: %s"):format(
            math.floor(FPS),
            info.Name
        )
        watermark_display:Set(text)
    end)

    -- ===== Menu =====
    menu_group:AddButton('Unload', function()
        goto_closest = false
        auto_start = false
        auto_redo = false
        kill_aura = false
        inf_jump = false
        tp_walk = false
        if watermark_connection then watermark_connection:Disconnect() end
        if speed_connection then speed_connection:Disconnect() end
        Rayfield:Destroy()
    end)

    menu_group:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'End',
        NoUI = true,
        Text = 'Menu keybind'
    })

    -- ===== Auto Execute After Teleport/Rejoin =====
    if queue_on_teleport then
        queue_on_teleport([[ loadstring(game:HttpGet('https://sirius.menu/rayfield'))() ]])
    end
end
