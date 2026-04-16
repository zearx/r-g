
local lp      = game:GetService("Players").LocalPlayer
local vim     = game:GetService("VirtualInputManager")
local run     = game:GetService("RunService")
local uis     = game:GetService("UserInputService")
local sgui    = game:GetService("StarterGui")

local enabled = false

local function notify(msg)
    pcall(sgui.SetCore, sgui, "SendNotification", {
        Title = "Auto Fishing",
        Text  = msg,
        Duration = 2,
    })
end

uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        enabled = not enabled
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
    if bar then bar.Size = UDim2.new(1, 0, 1.4, 0) end
end)

local function click(state)
    vim:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

task.spawn(function()
    while true do
        if not enabled then task.wait(0.5); continue end

        local bar = getBar()
        if not bar then
            click(true); task.wait(0.5); click(false)

            local elapsed = 0
            while enabled and not getBar() and elapsed < 30 do
                task.wait(0.5)
                elapsed += 0.5
            end
            task.wait(0.2)
        else
            while enabled and getBar() do
                click(true); task.wait(0.5); click(false); task.wait(0.1)
            end
            if enabled then task.wait(1.5) end
        end
    end
end)
