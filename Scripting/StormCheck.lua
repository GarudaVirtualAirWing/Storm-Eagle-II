-- GVAW Proportional Red Air Response --

-- Define RequiRed Variables --


local initPictureComplete = false

-- Define Flights Using MOOSE --

-- ISLANDS --

local function MIG23Suk()
		MIG23Suk = SPAWN:New("MIG23Suk")
		:InitLimit(2, 30)
		:SpawnScheduled(1800, 0.25)
		:InitRepeatOnLanding()
end
	
local function MIG29Suk()
		MIG29Suk = SPAWN:New("MIG29Suk")
		:InitLimit(2, 30)
		:SpawnScheduled(1800, 0.25)
		:InitRepeatOnLanding()
end
	
local function TU22Suk()
		TU22Suk = SPAWN:New("TU22Suk")
		:InitLimit(2, 30)
		:SpawnScheduled(1800, 0.25)
		:InitRepeatOnLanding()
end
	
local function SU27Tbilisi()
		SU27Tbilisi = SPAWN:New("SU27Tbilisi")
		:InitLimit(2, 30)
		:SpawnScheduled(1800, 0.25)
		:InitRepeatOnLanding()
end

local function SU34Tbilisi()
		SU34Tbilisi = SPAWN:New("SU34Tbilisi")
		:InitLimit(2, 30)
		:SpawnScheduled(2000, 0.25)
end

local function M2KTbilsi()
		M2KTbilsi = SPAWN:New("M2KTbilsi")
		:InitLimit(2, 30)
		:SpawnScheduled(1800, 0.25)
end

local function TU95Tbilisi()
	TU95Tbilisi = SPAWN:New("TU95Tbilisi")
	:InitLimit (2, 16)
	:SpawnScheduled(2800, 0.25)
end

local function SU33Kuz()
	SU33Kuz = SPAWN:New("SU33Kuz")
	:InitLimit (2, 16)
	:SpawnScheduled(1900, 0.25)
end

local function MIG21Tbilisi()
	MIG21Tbilisi = SPAWN:New("MIG21Tbilisi")
	:InitLimit (2, 16)
	:SpawnScheduled(2500, 0.25)
end


--Define Variations of Above Flights--

local function VariationA(threat)

	if initPictureComplete == false then
		
		MIG23Suk()
		MIG29Suk()
		TU22Suk()
		SU27Tbilisi()
		SU34Tbilisi()
		M2KTbilsi()
		TU95Tbilisi()
		SU33Kuz()
		MIG21Tbilisi()
		
		env.info("PROP-AIR: Variation A default state initiated.")
		initPictureComplete = true
	end

	if threat == 3 then
		SU34Tbilisi:SpawnScheduleStop()
		M2KTbilsi:SpawnScheduleStop()
		TU95Tbilisi:SpawnScheduleStop()
		SU33Kuz:SpawnScheduleStop()
		MIG21Tbilisi:SpawnScheduleStop()
	
	elseif threat == 2 then
		SU34Tbilisi:SpawnScheduleStop()
		M2KTbilsi:SpawnScheduleStop()
		TU95Tbilisi:SpawnScheduleStop()
		SU33Kuz:SpawnScheduleStop()
		MIG21Tbilisi:SpawnScheduleStart()	
		
	elseif threat == 1 then
		SU34Tbilisi:SpawnScheduleStop()
		M2KTbilsi:SpawnScheduleStop()
		TU95Tbilisi:SpawnScheduleStart()
		SU33Kuz:SpawnScheduleStart()
		MIG21Tbilisi:SpawnScheduleStop()

	else	
		SU34Tbilisi:SpawnScheduleStart()
		M2KTbilsi:SpawnScheduleStart()
		TU95Tbilisi:SpawnScheduleStop()
		SU33Kuz:SpawnScheduleStop()
		MIG21Tbilisi:SpawnScheduleStop()
	end	
end


-- Check Blue Air Player Assets and Schedule a Response Accordingly --

local function checkBlueAir()

	env.info("PROP-AIR: Check Blue Air Function started!")

	local fighterValue = 0
	local strikerValue = 0
	local airThreatValue = 0
	local airThreatLevel = 0
		
	local playerTable = {}
	playerTable = coalition.getPlayers(2)
		
	if #playerTable < 1 then
	
		airThreatValue = 0
		
	else
		for i = 1, #playerTable do
		
			if	playerTable[i]:getTypeName() == "A-10A" 	or
				playerTable[i]:getTypeName() == "A-10C" 	or
				playerTable[i]:getTypeName() == "AV-8B" 	or
				playerTable[i]:getTypeName() == "AJS37" 	or
				playerTable[i]:getTypeName() == "SU-25T" 	or
				playerTable[i]:getTypeName() == "F-5E-3" 	or
				playerTable[i]:getTypeName() == "MiG-21Bis" then
				
				strikerValue = strikerValue + 1
				
			else
				
				fighterValue = fighterValue + 1
				
			end
		end
			
		airThreatValue = (strikerValue / 2) + fighterValue
		
	end
					
	if airThreatValue <= 5 then
	
		airThreatLevel = 0
		
	elseif airThreatValue > 5 and airThreatValue <= 12 then
	
		airThreatLevel = 1
		
	elseif airThreatValue > 12 and airThreatValue <= 20 then
	
		airThreatLevel = 2
	
	elseif airThreatValue > 20 then
	
		airThreatLevel = 3
		
	end		

	VariationA(airThreatLevel)

		
		
	env.info("PROP-AIR: Check Blue Air Function finished!")
	return timer.getTime() + 300
end

-- Initiate checkBlueAir Schedule --

local function RedAirInit()

	env.info("PROP-AIR: Initiated!")
	timer.scheduleFunction(checkBlueAir, nil, timer.getTime() + 1)

end

RedAirInit()