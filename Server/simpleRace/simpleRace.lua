--	Simple race plugin by Fabuloup

pluginPath = debug.getinfo(1).source:gsub("\\","/")
pluginPath = pluginPath:sub(2,(pluginPath:find("simpleRace.lua"))-2)

package.path = package.path .. ";;" .. pluginPath .. "/?.lua;;".. pluginPath .. "/lua/?.lua"

local json = require("json")

--server config
local countdownCounter = 5
local numLap = 1
local isRaceGoingOn = false

--client config
local config = {
	racelineRadius = 1.5
}

-- internal variables
local timeboard = {}

function onInit()
	MP.RegisterEvent("onChatMessage","onChatMessage")
	MP.RegisterEvent("SRendLap","updateTimeboard")

	clog("--------------Simple Race Ready--------------", true)
end

------------------------------ FUNCTIONS ------------------------------

function sendConfig(newcfg)
	newcfg = newcfg or {}

	config.inactiveColor = newcfg.inactiveColor or config.inactiveColor
	config.activeColor = newcfg.activeColor or config.activeColor
	config.wonColor = newcfg.wonColor or config.wonColor

	local cfg = json.encode(config):gsub(':',';')

	MP.TriggerClientEvent(-1, "SRsetConfig", cfg)
end

function initTimeboard()
	timeboard = {}
	for k, v in pairs(MP.GetPlayers()) do timeboard[v] = {starttime=os.time(), laps=0} end
end

------------------------------ RACE EVENTS ------------------------------

function updateTimeboard(playerID, data) -- call at the end of the player lap
	data = string.gsub(data, ";", ":")
	data = json.decode(data)

	local playerName = MP.GetPlayerName(playerID)
	local lineCrossing = os.time()
	local laptime = lineCrossing-timeboard[playerName]['starttime']

	local laptimeMsg = "["..string.sub(playerName,1,12)
	for i=1,13-#laptimeMsg do
		laptimeMsg = laptimeMsg.." "
	end
	laptimeMsg = laptimeMsg.."] "..os.date('%M:%S', laptime)

	timeboard[playerName]['starttime'] = lineCrossing
	timeboard[playerName]['laps'] = timeboard[playerName]['laps']+1

	MP.SendChatMessage(-1, laptimeMsg)

	if data.laps >= numLap then
		MP.TriggerClientEvent(-1, "SRresetRace", tostring(countdownCounter))
	end
end

function doCountdown()
	if countdownCounter <= 0 then
		MP.CancelEventTimer("countdownEvent")
		return
	end
	if countdownCounter == 0 then
		MP.SendChatMessage(-1, "Go!")
		initTimeboard()
		MP.TriggerClientEvent(-1, "SRstartRace", tostring(numLap))
	else
		MP.SendChatMessage(-1, tostring(countdownCounter))
	end
	countdownCounter = countdownCounter - 1
end

function startCountdown()
	MP.SendChatMessage(-1, "Race starting in...")
	countdownCounter = 5
	MP.RegisterEvent("countdownEvent", "doCountdown")
	MP.CreateEventTimer("countdownEvent", 1000)

	MP.TriggerClientEvent(-1, "SRresetRace", tostring(countdownCounter))
	sendConfig()
end

function stopRace()
	timeboard = {}
	MP.TriggerClientEvent(-1, "SRresetRace", tostring(countdownCounter))
end

------------------------------ MP EVENTS ------------------------------

function onChatMessage(playerID, name ,chatMessage)
	chatMessage = chatMessage:sub(1)
	local playerName = MP.GetPlayerName(playerID)

	if chatMessage:find("/startrace") then
		clog("player "..name.." started a race", true)
		startCountdown()
		return 1
	elseif chatMessage:find("/stoprace") then
		stopRace()
		return 1
	elseif starts_with(chatMessage, "/setlap") then
		numLap = tonumber((chatMessage:gsub("/setlap ", "")))
		MP.SendChatMessage(-1, playerName.." set the lap number to "..tostring(numLap))
		return 1
	elseif starts_with(chatMessage, "/help") then
		MP.SendChatMessage(playerID, "/startrace				[SR] Start a race")
		MP.SendChatMessage(playerID, "/stoprace				[SR] Stop the race")
		MP.SendChatMessage(playerID, "/setlap [nb of laps]	[SR] Set the number of lap for the race")
		return 1
	end
end

------------------------------ DEBUG ------------------------------

function tableToString(t, oneLine)
	oneLine = oneLine or true
	local str = ""

	for k,v in pairs(t) do
		str = str.." "..k.." : ".. (type(v) == "table" and tableToString(v) or v)
		if not oneLine then
			str = str.."\n"
		end
	end
	return str
end
function clog(text)
	if text == nil then
		return
	end

	if type(text) == "table" then
		text = tableToString(text)
	end

	print(" [simpleRace] "..text)

	if false then
		file = io.open("log.txt", "a")
		file:write(os.date("[%d/%m/%Y %H:%M:%S] ")..text.."\n")
		file:close()
	end
end

------------------------------ MISC ------------------------------

function starts_with(str, start)
   return str:sub(1, #start) == start
end