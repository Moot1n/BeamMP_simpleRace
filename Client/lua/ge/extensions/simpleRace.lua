--Simple Race by Fabuloup

local M = {}


M.dependencies = {"ui_imgui"}

local gui_module = require("ge/extensions/editor/api/gui")
local gui = {setupEditorGuiTheme = nop}
local imgui = ui_imgui

local raceStarted = false
local racelinePos = nil
local racelineRadius = 1.2
local canPassRaceline = false
local numLap = 0
local lapStartTime = 0
local timeCounter = 0 -- time, in seconds

-- Helpers

local function mapValue(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end
local function constrain(x, in_min, in_max)
	if x > in_max then return in_max
	elseif x < in_min then return in_min
	else return x end
end
local function spairs(t, order) -- sorts pairs
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
local function distance2D(pos1, pos2)
	return math.sqrt(math.pow(pos1.x-pos2.x,2)+math.pow(pos1.y-pos2.y,2))
end

-- GUI

local function hideNicknames(hide)
	MPVehicleGE.hideNicknames(hide)
end

local function onUpdate(dt)
	timeCounter = timeCounter+dt
	if raceStarted then
		local racelinePosTop = Point3F(racelinePos.x, racelinePos.y, racelinePos.z+2+mapValue(math.sin(timeCounter*1.5),0,1,0,0.5))
		local racelinePosBottom = Point3F(racelinePos.x, racelinePos.y, racelinePos.z-1)

		debugDrawer:drawCylinder(racelinePosBottom, racelinePosTop, racelineRadius, ColorF(0.6,0,0.7,0.5))

		-- detect end of lap
		for i = 0, be:getObjectCount()-1 do
			local veh = be:getObject(i)
			if MPVehicleGE.isOwn(veh:getID()) then
				if canPassRaceline and distance2D(veh:getPosition(), racelinePos) < racelineRadius*1.5 then --pass the line
					canPassRaceline = false
					numLap = numLap + 1
					local sendObject = {
						laps = numLap
						lapTime = timeCounter-lapStartTime
					}
					local strObject = jsonEncode(sendObject)
					strObject = strObject:gsub(":", ";")

					TriggerServerEvent("SRendLap", strObject)

					lapStartTime = timeCounter
					-- hideNicknames(true)
				elseif canPassRaceline == false and distance2D(veh:getPosition(), racelinePos) > racelineRadius*2 then
					canPassRaceline = true
				end
				break
			end
		end
	end
end

-- Events

local function setConfig(config)
	config = config:gsub(';',':')
	config = jsonDecode(config)

	dump(config)

	racelineRadius = config.racelineRadius and tonumber(config.racelineRadius) or racelineRadius
end

local function resetRace(data)
	--data = data:gsub(';',':')
	--data = jsonDecode(data)

	raceStarted = false
	canPassRaceline = false
	numLap = 0
	print('[SR] Reset the race')
end

local function startRace(data)
	--data = data:gsub(';',':')
	--data = jsonDecode(data)

	local vid = be:getPlayerVehicleID(0)
	local vehicle = be:getObjectByID(vid)
	racelinePos = vehicle:getPosition()

	raceStarted = true
	numLap = 0
	lapStartTime = timeCounter
	print('[SR] Start the race')
end

if MPGameNetwork then -- just so we dont instantly error out without BeamMP
	AddEventHandler("SRsetConfig",				setConfig)
	AddEventHandler("SRresetRace",				resetRace)
	AddEventHandler("SRstartRace",				startRace)
end

M.onUpdate				= onUpdate

print("Simple Race client loaded ~~")

return M