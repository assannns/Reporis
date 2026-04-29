-- TP SAVER SCRIPT (FIXED DRAG)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- File paths
local SAVE_FOLDER = "TeleportSaves"
local SAVE_FILE = "positions.json"
local savePath = SAVE_FOLDER .. "/" .. SAVE_FILE

if isfolder and not isfolder(SAVE_FOLDER) then
    pcall(function() makefolder(SAVE_FOLDER) end)
end

local savedPositions = {}

local function loadPositions()
    if not isfile or not savePath then return end
    local success, data = pcall(function() return readfile(savePath) end)
    if success and data and data ~= "" then
        local decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if decoded and type(decoded) == "table" then
            savedPositions = decoded
        end
    end
end

local function savePositions()
    if not writefile or not savePath then return end
    local encoded = HttpService:JSONEncode(savedPositions)
    pcall(function() writefile(savePath, encoded) end)
end

-- UI Elements
local screenGui = nil
local mainFrame = nil
local scrollFrame = nil
local items = {}

local function refreshList()
    if not scrollFrame then return end
    
    for _, v in pairs(items) do
        pcall(function() v:Destroy() end)
    end
    items = {}
    
    local yOffset = 0
    for i, pos in ipairs(savedPositions) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, -20, 0, 55)
        item.Position = UDim2.new(0, 10, 0, yOffset)
        item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        item.Parent = scrollFrame
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
        
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -120, 0, 22)
        name.Position = UDim2.new(0, 10, 0, 5)
        name.BackgroundTransparency = 1
        name.Text = pos.name or "Unknown"
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 13
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = item
        
        local coords = Instance.new("TextLabel")
        coords.Size = UDim2.new(1, -120, 0, 18)
        coords.Position = UDim2.new(0, 10, 0, 27)
        coords.BackgroundTransparency = 1
        coords.Text = string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z)
        coords.TextColor3 = Color3.fromRGB(160, 160, 160)
        coords.Font = Enum.Font.Gotham
        coords.TextSize = 10
        coords.TextXAlignment = Enum.TextXAlignment.Left
        coords.Parent = item
        
        local tp = Instance.new("TextButton")
        tp.Size = UDim2.new(0, 70, 0, 28)
        tp.Position = UDim2.new(1, -85, 0.5, -14)
        tp.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        tp.Text = "Teleport"
        tp.TextColor3 = Color3.fromRGB(255, 255, 255)
        tp.Font = Enum.Font.GothamBold
        tp.TextSize = 11
        tp.Parent = item
        Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)
        
        tp.MouseButton1Click:Connect(function()
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos.x, pos.y, pos.z)
                TweenService:Create(tp, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 160, 240)}):Play()
                task.delay(0.2, function()
                    TweenService:Create(tp, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play()
                end)
            end
        end)
        
        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 28, 0, 28)
        del.Position = UDim2.new(1, -45, 0.5, -14)
        del.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
        del.Text = "X"
        del.TextColor3 = Color3.fromRGB(255, 255, 255)
        del.Font = Enum.Font.GothamBold
        del.TextSize = 12
        del.Parent = item
        Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)
        
        del.MouseButton1Click:Connect(function()
            table.remove(savedPositions, i)
            savePositions()
            refreshList()
            task.wait(0.1)
            local totalHeight = #savedPositions * 60 + 20
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 300))
            mainFrame.Size = UDim2.new(0, 350, 0, math.min(totalHeight + 110, 500))
        end)
        
        table.insert(items, item)
        yOffset = yOffset + 60
    end
    
    local totalHeight = #savedPositions * 60 + 20
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 300))
    mainFrame.Size = UDim2.new(0, 350, 0, math.min(totalHeight + 110, 500))
end

local function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportSaver"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044889"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    title.Text = "Teleport Saver"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 35)
    saveBtn.Position = UDim2.new(0, 10, 0, 50)
    saveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    saveBtn.Text = "Save Current Position"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 13
    saveBtn.Parent = mainFrame
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    
    saveBtn.MouseButton1Click:Connect(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.Position
        local name = "Position " .. (#savedPositions + 1)
        table.insert(savedPositions, {
            name = name,
            x = pos.X,
            y = pos.Y,
            z = pos.Z
        })
        savePositions()
        refreshList()
    end)
    
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -110)
    scrollFrame.Position = UDim2.new(0, 0, 0, 95)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- DRAG FIX: Use mouse delta properly
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = mainFrame.Position
        end
    end
    
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentPos - dragStart
            mainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end
    
    title.InputBegan:Connect(onInputBegan)
    UIS.InputChanged:Connect(onInputChanged)
    UIS.InputEnded:Connect(onInputEnded)
end

loadPositions()
createUI()
refreshList()

print("Teleport Saver loaded. Drag fixed.")
