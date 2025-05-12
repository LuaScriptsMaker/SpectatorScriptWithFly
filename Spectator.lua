-- Создаем кнопку
local button = Instance.new("TextButton")
button.Name = "FlyButton"
button.Text = "Fly"
button.Size = UDim2.new(0, 150, 0, 45)
button.Position = UDim2.new(0.864, 0, 0.582, 0)
button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 26
button.Font = Enum.Font.SourceSansBold
button.ZIndex = 10

-- Добавляем скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Добавляем обводку
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(35, 35, 35)
stroke.Thickness = 5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = button

-- Вставляем кнопку в родительский GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ExploitGui"
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
button.Parent = gui

-- Конфигурация полёта
local flyspeed = 50
local controls = {
    front = "s",  -- Вперёд (по вашим настройкам)
    back = "w",   -- Назад
    right = "d",  -- Вправо
    left = "a",   -- Влево
    up = "space",       -- Вверх
    down = "leftcontrol", -- Вниз
    add_speed = "rightbracket",    -- + скорость
    sub_speed = "leftbracket",     -- - скорость
    reset_speed = "minus"          -- сброс скорости
}

local player = game:GetService("Players").LocalPlayer
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local flycontrol = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}
local flying = false
local flyCon = nil
local bv, bg = nil, nil
local flyAnimation = nil
local animator = nil

local function stopFlying()
    if flyCon then
        flyCon:Disconnect()
        flyCon = nil
    end
    
    -- Останавливаем анимацию
    if flyAnimation and animator then
        flyAnimation:Stop()
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                    v:Destroy()
                end
            end
        end
    end
    
    bv, bg = nil, nil
    flyAnimation = nil
    animator = nil
end

local function startFlying()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    stopFlying() -- Очищаем предыдущие эффекты
    
    -- Загружаем анимацию полёта
    animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    flyAnimation = Instance.new("Animation")
    flyAnimation.AnimationId = "rbxassetid://125750759"
    flyAnimation = animator:LoadAnimation(flyAnimation)
    flyAnimation:Play()

	   flyAnimation.Looped = true
    flyAnimation:Play()
    
    flying = true
    button.Text = "Fly"
    button.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    
    bv = Instance.new("BodyVelocity")
    bg = Instance.new("BodyGyro")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1000
    bg.D = 100
    bv.Parent = hrp
    bg.Parent = hrp
    
    flyCon = runservice.Heartbeat:Connect(function(dt)
        if not flying or not player.Character or not humanoid.Parent then
            stopFlying()
            return
        end
        
        humanoid.PlatformStand = true
        bg.CFrame = workspace.CurrentCamera.CoordinateFrame
        
        local direction = Vector3.new(
            flycontrol.R - flycontrol.L,
            flycontrol.U - flycontrol.D,
            flycontrol.B - flycontrol.F  -- Обратите внимание: B - F (по вашим настройкам)
        )
        
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        
        local cam = workspace.CurrentCamera
        local moveVec = cam.CFrame.RightVector * direction.X * flyspeed +
                        cam.CFrame.UpVector * direction.Y * flyspeed +
                        cam.CFrame.LookVector * direction.Z * flyspeed
        
        bv.Velocity = moveVec
    end)
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    if flying then
        flying = false
        button.Text = "Fly"
        button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        stopFlying()
    else
        startFlying()
    end
end)

-- Обработчики клавиш (сохранены как у вас)
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode.Name:lower()
    
    if key == controls.front then
        flycontrol.F = 1
    elseif key == controls.back then
        flycontrol.B = 1
    elseif key == controls.right then
        flycontrol.R = 1
    elseif key == controls.left then
        flycontrol.L = 1
    elseif key == controls.up then
        flycontrol.U = 1
    elseif key == controls.down then
        flycontrol.D = 1
    elseif key == controls.add_speed then
        flyspeed = math.min(flyspeed + 10, 200)
    elseif key == controls.sub_speed then
        flyspeed = math.max(flyspeed - 10, 10)
    elseif key == controls.reset_speed then
        flyspeed = 50
    end
end)

uis.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode.Name:lower()
    
    if key == controls.front then
        flycontrol.F = 0
    elseif key == controls.back then
        flycontrol.B = 0
    elseif key == controls.right then
        flycontrol.R = 0
    elseif key == controls.left then
        flycontrol.L = 0
    elseif key == controls.up then
        flycontrol.U = 0
    elseif key == controls.down then
        flycontrol.D = 0
    end
end)

-- Сброс при смене персонажа
player.CharacterAdded:Connect(function(character)
    flying = false
    button.Text = "Fly"
    button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    stopFlying()
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        flying = false
        button.Text = "Fly"
        button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        stopFlying()
    end)
end)

-- Проверяем, работает ли эксплоит
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Ждем, пока все части персонажа загрузятся
while not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") do
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    wait(0.1)
end

-- Функция для изменения прозрачности
local function setTransparency(part, transparency)
    if part:IsA("BasePart") then
        part.Transparency = transparency
        if part:FindFirstChildOfClass("SurfaceAppearance") then
            part:FindFirstChildOfClass("SurfaceAppearance").Transparency = transparency
        end
    end
end

-- Делаем HumanoidRootPart полностью невидимым
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
setTransparency(humanoidRootPart, 1)

-- Делаем остальные части на 50% невидимыми
for _, part in ipairs(character:GetDescendants()) do
    if part:IsA("BasePart") and part ~= humanoidRootPart then
        setTransparency(part, 0.5)
    end
end

-- Обработчик для новых частей (если персонаж изменится)
character.DescendantAdded:Connect(function(part)
    if part:IsA("BasePart") then
        if part == humanoidRootPart then
            setTransparency(part, 1)
        else
            setTransparency(part, 0.5)
        end
    end
end)

print("Скрипт активирован: Игрок на 50% невидим, HumanoidRootPart на 100% невидим")

-- Ultra-Fast White Transparent MLG Particles (R6 Full Body) - ТОЛЬКО ДЛЯ СЕБЯ

local Players = game:GetService("Players")
local player = Players.LocalPlayer -- Получаем локального игрока

local function addParticlesToCharacter(character)
    local bodyParts = {
        "Head",
        "Torso",
        "Left Arm", "Right Arm",
        "Left Leg", "Right Leg"
    }
    
    for _, partName in ipairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part then
            local emitter = Instance.new("ParticleEmitter", part)
            
            -- Основные настройки
            emitter.Texture = "rbxassetid://241876428"
            emitter.VelocitySpread = 50
            emitter.Lifetime = NumberRange.new(0.25) -- 0.25 миллисекунды (0.00025 секунды)
            emitter.Rate = 385 -- Увеличен в 5 раз
            
            -- Настройки прозрачности (50%)
            emitter.Transparency = NumberSequence.new(0.5)
            
            -- Настройки цвета (белый)
            emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
            
            -- Настройки размера
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),  -- Начальный размер 0.5
                NumberSequenceKeypoint.new(1, 0.1)   -- Конечный размер 0.1
            })
        end
    end
end

-- Добавляем частицы при спавне персонажа
player.CharacterAdded:Connect(function(character)
    addParticlesToCharacter(character)
end)

-- Если персонаж уже есть (например, после повторного запуска скрипта)
if player.Character then
    addParticlesToCharacter(player.Character)
end
