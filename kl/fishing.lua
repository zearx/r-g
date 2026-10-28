local lp   = game:GetService("Players").LocalPlayer
local vim  = game:GetService("VirtualInputManager")
local run  = game:GetService("RunService")
local uis  = game:GetService("UserInputService")
local sgui = game:GetService("StarterGui")

local enabled = false
local savedCF = nil

local function notify(msg)
    pcall(function()
        sgui:SetCore("SendNotification", {
            Title    = "Auto Fishing",
            Text     = msg,
            Duration = 2,
        })
    end)
end

uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E then
        enabled = not enabled
        if enabled then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                savedCF = root.CFrame
            end
        else
            savedCF = nil
        end
        notify(enabled and "Enabled" or "Disabled")
    end
end)

local function getBar()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local ui = pg:FindFirstChild("FishingUI")
    if not ui then return nil end
    local bg = ui:FindFirstChild("FishingBackground")
    if not bg then return nil end
    return bg:FindFirstChild("FishingBar")
end

run.RenderStepped:Connect(function()
    if not enabled then return end
    local bar = getBar()
    if bar then
        bar.Size = UDim2.new(1, 0, 1.4, 0)
    end
end)

local function click(state)
    vim:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if enabled and savedCF then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - savedCF.Position).Magnitude > 2 then
                root.CFrame = savedCF
            end
        end
    end
end)

task.spawn(function()
    while true do
        if not enabled then
            task.wait(0.5)
        else
            local bar = getBar()
            if not bar then
                click(true)
                task.wait(0.5)
                click(false)

                local elapsed = 0
                while enabled and not getBar() and elapsed < 30 do
                    task.wait(0.5)
                    elapsed = elapsed + 0.5
                end
                task.wait(0.2)
            else
                while enabled and getBar() do
                    click(true)
                    task.wait(0.5)
                    click(false)
                    task.wait(0.1)
                end
                if enabled then
                    task.wait(1.5)
                end
            end
        end
    end
end)
