-- GVAW Operation Storm Eagle II --

local function logisticAssets()


	local function HOTEL()
	  HOTELSpawner = SPAWN:New("HOTEL")
	  :InitLimit(1, 1)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	 end
	 
	local function ACRO()
	  ARCOSpawner = SPAWN:New("ACRO")
	  :InitLimit(1, 1)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	 end
	 
	local function TEXACO()
	  TEXACOSpawner = SPAWN:New("TEXACO")
	  :InitLimit(1, 1)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	 end

	local function MAGIC()
	  MAGICSpawner = SPAWN:New("MAGIC")
	  :InitLimit(1, 1)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	 end
	 
	local function MAGICDEF()
	  MAGICDEFSpawner = SPAWN:New("MAGICDEF")
	  :InitLimit(1, 1)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	end
	 
	HOTEL()
	ACRO()
	TEXACO()
	MAGIC()
	MAGICDEF()

end

logisticAssets()
