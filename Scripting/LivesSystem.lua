-- Operation Storm Eagle II Lives System --

-- Define Required Variables and Functions --
LivesRemaining = 500
LivesAirborne = 0
LivesLost = 0
LivesMIA = 0
LivesAWOL = 0
LivesEventHandler = {}
MissionFailure = {}
F10MenuOptions = {}
AWOLPilots = {}

-- Define Useful Functions for Amending Variable Values --

function PlayerTakeoff()
	LivesRemaining = LivesRemaining - 1
	LivesAirborne = LivesAirborne + 1
		if LivesRemaining < 0
			then
				LivesRemaining = 0
		end
end

function PlayerLand()
	LivesRemaining = LivesRemaining + 1
	LivesAirborne = LivesAirborne - 1
		if LivesAirborne < 0
			then
				LivesAirborne = 0
		end
end

function PlayerDie()
	LivesAirborne = LivesAirborne - 1
	LivesLost = LivesLost + 1
	if LivesLost < 0
		then
			LivesLost = 0
	end
end

function PlayerMIA()
	LivesMIA = LivesMIA + 1
	LivesAirborne = LivesAirborne - 1
		if LivesAirborne < 0
			then
				LivesAirborne = 0
		end
end

function PlayerRecovered()
	LivesLost = LivesLost - 1
	LivesRemaining = LivesRemaining + 1
		if
			LivesLost < 0
				then
					LivesLost = 0
		end
end

function PlayerAWOL()
	LivesAirborne = LivesAirborne - 1
	LivesAWOL = LivesAWOL + 1
		if LivesAirborne < 0
			then
				LivesAirborne = 0
		end
end

function PlayerNotAWOL()
	LivesAWOL = LivesAWOL - 1
	LivesAirborne = LivesAirborne + 1
		if LivesAWOL < 0
			then
				LivesAWOL = 0
		end
end
	
-- Define Actions on Player Events --
	
function LivesEventHandler:onEvent(event)
	if (event.id == world.event.S_EVENT_TAKEOFF or event.id == world.event.S_EVENT_LAND) and event.initiator and event.initiator:getPlayerName() ~= nil and event.initiator:hasAttribute("Helicopters")
		then
			trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "Helicopters not yet implemented into Lives System. WIP.", 10, 1)
	elseif (event.initiator and event.id == world.event.S_EVENT_TAKEOFF and event.place:getTypeName() == "Kobuleti" and event.initiator:getPlayerName() ~= nil) or (event.initiator and event.id == world.event.S_EVENT_TAKEOFF and event.place:getTypeName() == "Batumi" and event.initiator:getPlayerName() ~= nil) 
		or (event.initiator and event.id == world.event.S_EVENT_TAKEOFF and event.place:getTypeName() == "Stennis - airbase" and event.initiator:getPlayerName() ~= nil) or (event.initiator and event.id == world.event.S_EVENT_TAKEOFF and event.place:getTypeName() == "LHA_Tarawa - airbase" and event.initiator:getPlayerName() ~= nil)
		then
			if event.initiator:getTypeName() == "F-14B"
				then
					PlayerTakeoff()
					PlayerTakeoff()
					trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "You have taken off and a life has been removed from the team for both crew members! Land safely at either Batumi, Kobuleti or the Carrier to return your lives to the pool. Good luck!", 10, 1)
			else
				PlayerTakeoff()
				local DepartedPilot = event.initiator
				trigger.action.outTextForGroup(DepartedPilot:getGroup():getID(), "You have taken off and a life has been removed from the team. Land safely at either Batumi, Kobuleti or the Carrier to return your life to the pool. Good luck!", 10, 1)
				--env.info("TAKEOFF EVENT RUN")
			end
			
	elseif event.id == 3 and event.initiator and event.initiator:getPlayerName() ~= nil
		then
			if event.initiator:getTypeName() == "F-14B"
				then
					PlayerNotAWOL()
					PlayerNotAWOL()
					trigger.action.outTextForGroup(NotAWOLPilot:getGroup():getID(), "You have taken off again and are no longer considered AWOL. Return to Batumi, Kobuleti or the Carrier to return your lives to the pool.", 30, 1)
					AWOLPilots[event.initiator:getPlayerName()] = nil
			else
					PlayerNotAWOL()
					local NotAWOLPilot = event.initiator
					trigger.action.outTextForGroup(NotAWOLPilot:getGroup():getID(), "You have taken off again and are no longer considered AWOL. Return to Batumi, Kobuleti or the Carrier to return your life to the pool.", 30, 1)
					AWOLPilots[event.initiator:getPlayerName()] = nil
			end
			
	elseif (event.initiator and event.id == 4 and event.place:getTypeName() == "Kobuleti" and event.initiator:getPlayerName() ~= nil) or (event.initiator and event.id == 4 and event.place:getTypeName() == "Batumi" and event.initiator:getPlayerName() ~= nil) 
		or (event.initiator and event.id == 4 and event.place:getTypeName() == "Stennis - airbase" and event.initiator:getPlayerName() ~= nil) or (event.initiator and event.id == 3 and event.place:getTypeName() == "LHA_Tarawa - airbase" and event.initiator:getPlayerName() ~= nil)
		then 
			--env.info("LANDING DETECTED")
			local LandedPilot = event.initiator
			timer.scheduleFunction(LandingLifeCheck, LandedPilot, timer.getTime()+1)
			--env.info("SCHEDULED CHECK FUNCTION")
	elseif event.id == world.event.S_EVENT_LAND and event.initiator and event.initiator:getPlayerName() ~= nil
		then
			--env.info("LANDING AT WRONG AIRBASE DETECTED")
			local LandedPilot = event.initiator
			timer.scheduleFunction(AWOLLandingLifeCheck, LandedPilot, timer.getTime()+1)
			--env.info("SCHEDULED AWOL CHECK FUNCTION")

	elseif event.id == world.event.S_EVENT_PILOT_DEAD and event.initiator and event.initiator:getPlayerName() ~= nil
		then
			PlayerDie()
			local KilledPilot = event.initiator
			trigger.action.outTextForGroup(KilledPilot:getGroup():getID(), "You have been killed in action. Your life has been added to the death toll. Be more careful next time!", 10, 1)
			--env.info("DEATH EVENT RUN")

	elseif event.id == world.event.S_EVENT_EJECTION and event.initiator and event.initiator:getPlayerName() ~= nil and event.initiator:inAir() == true
		then
			PlayerMIA()
			local EjectedPilot = event.initiator
			--trigger.action.outTextForCoalition(2, EjectedPilot:getPlayerName().." has ejected safely and a CSAR mission is available to rescue them! Use the F10 Menu for more information. (STILL INACTIVE)", 10, 1) -- This line will be removed as Ali's CSAR Script sends the CSAR message.
			--env.info("EJECT EVENT RUN")
	elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT and event.initiator and event.initiator:inAir() == true
		then
			PlayerDie()
			--env.info("DISCONNECT EVENT RUN")
	end
end

function LandingLifeCheck(PilotOnGround)
	--env.info("RUNNING LIFE CHECK")
	local PilotsLife = PilotOnGround:getLife()
	--env.info(PilotsLife)
		if PilotsLife > 0
			then
				if PilotOnGround:getTypeName() == "F-14B"
					then
						PlayerLand()
						PlayerLand()
						trigger.action.outTextForGroup(PilotOnGround:getGroup():getID(), "Welcome back! You have landed safely and your lives has been returned to the team. Great job!", 10, 1)
				else
				--env.info("PLAYER IS ALIVE")
				PlayerLand()
				trigger.action.outTextForGroup(PilotOnGround:getGroup():getID(), "Welcome back! You have landed safely and your life has been returned to the team. Great job!", 10, 1)
				--env.info("LANDING EVENT RUN")
			end
		end
end
		
function AWOLLandingLifeCheck(PilotOnGround)
	--env.info("RUNNING AWOL LIFE CHECK")
	local PilotsLife = PilotOnGround:getLife()
	local PilotsName = PilotOnGround:getPlayerName()
	--env.info(PilotsLife)
		if PilotsLife > 0
			then
				if PilotOnGround:getTypeName() == "F-14B"
					then
						PlayerAWOL()
						PlayerAWOL()
						trigger.action.outTextForGroup(PilotOnGround:getGroup():getID(), "You have successfully landed, but not at a NATO base. You and your RIO are currently considered AWOL. You have 15 minutes to take off again before you are considered KIA! Return to either Batumi, Kobuleti or the Carrier to return your lives to the pool.", 60, 1)
						timer.scheduleFunction(AWOLCheck, PilotsName, timer.getTime() + 900)
				else
				--env.info("PLAYER IS AWOL")
				PlayerAWOL()
				AWOLPilots[PilotsName] = true
				trigger.action.outTextForGroup(PilotOnGround:getGroup():getID(), "You have successfully landed, but not at a NATO base. You are currently considered AWOL. You have 15 minutes to take off again before you are considered KIA! Return to either Batumi, Kobuleti or the Carrier to return your life to the pool.", 60, 1)
				timer.scheduleFunction(AWOLCheck, PilotsName, timer.getTime() + 900)
				--env.info("AWOL EVENT RUN")
			end
		end
end

function AWOLCheck(PlayerName)
	if AWOLPilots[PlayerName] == true
		then
			PlayerDie()
			AWOLPilots[PlayerName] = nil
	end
end

-- Define Function for actioning Mission Failure --

function RestartMission()
	net.load_next_mission()
end

function MissionFailure:onEvent(event)
	if event.id == world.event.S_EVENT_PILOT_DEAD and event.initiator and event.initiator:getPlayerName() ~= nil and LivesLost > 500
		then
			trigger.action.outTextForCoalition(2, "The death toll of Operation Storm Eagle II has soared too high. Public opinion of the Operation has fallen and units are being pulled out of the Persian Gulf. Mission Failed.", 60, 1)
			timer.scheduleFunction(RestartMission, {}, timer.getTime()+60)
		end
end



-- Operation Storm Eagle II CSAR Script --

local SpawnDownedPilot = SPAWN:New("DownedPilot")
NumberCSARMissions = 0
CSARPilotsOnBoard = {}
NewCSARMission = {}
CSARDropoff = {}
ActiveCSARFrequencies = {}



function NewCSARMission:onEvent(event)
	if event.initiator == nil
		then
			--env.info("Event Initiator was nil")
	elseif event.id == world.event.S_EVENT_EJECTION and event.initiator and event.initiator:getPlayerName() ~= nil and event.initiator:inAir() == true
		then
			--env.info("Ran New CSAR Mission event")
			NumberCSARMissions = NumberCSARMissions + 1  
			local EjectedPlayer = event.initiator
			local EjectedPlayerVec3 = EjectedPlayer:getPoint()
			local EjectedPlayerCoordinate = COORDINATE:NewFromVec3(EjectedPlayerVec3)
			local NearestRoad = EjectedPlayerCoordinate:GetClosestPointToRoad()
			local NearestRoadVec2 = NearestRoad:GetVec2() 
			local SpawnedPilot = SpawnDownedPilot:SpawnFromVec2(NearestRoadVec2)
			local SpawnedPilotPosition = SpawnedPilot:GetVec3()
			local PilotFrequency = math.random(45, 69)  
			local FreqForMessage = event.initiator:getPlayerName()..": "..PilotFrequency..".00 mHz FM"
			ActiveCSARFrequencies[#ActiveCSARFrequencies + 1] = FreqForMessage
			PilotFrequency = PilotFrequency*1000000
			local setFrequency = { 
				id = 'SetFrequency', 
				params = {
					frequency = PilotFrequency,
					modulation = radio.modulation.FM, 
				} 
			}
			local DownedPilot = Group.getByName('DownedPilot#00' ..NumberCSARMissions)
			local DownedPilotUnit = DownedPilot:getUnit(1)
			local DownedPilotPos = DownedPilotUnit:getPoint()
			local DownedPilotController = Group.getController(DownedPilot)
			DownedPilotController:setCommand(setFrequency)
			trigger.action.outTextForCoalition(2, EjectedPlayer:getPlayerName().." has been hit and is going down! Initial reports suggest a good chute, and a CSAR mission is being readied to rescue him. Use the F10 menu for more information.", 20, 1)
			local foundObjects = {}
			timer.scheduleFunction(CSARAreaSearch, {DownedPilotUnit, foundObjects, DownedPilot, FreqForMessage}, timer.getTime()+ 10)
			--env.info("Scheduled CSAR Searching Function")
		end
end

function CSARAreaSearch(ParamTable)
	--env.info("Entered CSAR Search Function")
	local Pilot = ParamTable[1]
	local foundObjects = ParamTable[2]
	local PilotPosition = Pilot:getPoint()
	local PilotGroup = ParamTable[3]
	local ActiveFrequency = ParamTable[4]
	local CSARSearchZone = {
		id = world.VolumeType.SPHERE,
		params = {
			point = PilotPosition,
			radius = 100
			}
		}
	world.searchObjects(Object.Category.UNIT, CSARSearchZone, ifFoundUnit, foundObjects)
	--env.info("Search of CSAR Zone complete, found " ..#foundObjects)
	if #foundObjects >= 1
		then
			foundObjectsName = foundObjects[1]
			PlayerCSARCount = trigger.misc.getUserFlag(foundObjectsName.."CSARCount")
			--env.info("Found something, running CSAR Pickup event")
				if PlayerCSARCount < 1
					then
						trigger.action.setUserFlag(foundObjectsName.."CSARCount", 1)
						trigger.action.outTextForGroup(foundObjectsName, "You have successfully picked up the pilot! Get him back to the nearest NATO airbase or FARP to complete the CSAR mission!", 20, 1)
						trigger.action.deactivateGroup(PilotGroup)
						trigger.action.outTextForGroup(foundObjectsName, "Pilots on board: 1/4", 20, 1)
						for i = 1, #ActiveCSARFrequencies
							do
								local FreqToRemove = ActiveCSARFrequencies[i]
									if
										FreqToRemove == ActiveFrequency
											then
												table.remove(ActiveCSARFrequencies, i)
											
									end
							end
						local FirstFlagCheck = trigger.misc.getUserFlag(foundObjectsName.."CSARCount")
						--env.info("Completed Pickup Function")
				elseif PlayerCSARCount == 1
					then
						trigger.action.setUserFlag(foundObjectsName.."CSARCount", 2)
						trigger.action.outTextForGroup(foundObjectsName, "You have successfully picked up the pilot! Get him back to the nearest NATO airbase or FARP to complete the CSAR mission!", 20, 1)
						trigger.action.deactivateGroup(PilotGroup)
						trigger.action.outTextForGroup(foundObjectsName, "Pilots on board: 2/4", 20, 1)
						for i = 1, #ActiveCSARFrequencies
							do
								local FreqToRemove = ActiveCSARFrequencies[i]
									if
										FreqToRemove == ActiveFrequency
											then
												table.remove(ActiveCSARFrequencies, i)
											
									end
							end
						local SecondFlagCheck = trigger.misc.getUserFlag(foundObjectsName.."CSARCount")
						--env.info("Completed Pickup Function")
				elseif PlayerCSARCount == 2
					then
						trigger.action.setUserFlag(foundObjectsName.."CSARCount", 3)
						trigger.action.outTextForGroup(foundObjectsName, "You have successfully picked up the pilot! Get him back to the nearest NATO airbase or FARP to complete the CSAR mission!", 20, 1)
						trigger.action.deactivateGroup(PilotGroup)
						trigger.action.outTextForGroup(foundObjectsName, "Pilots on board: 3/4", 20, 1)
						for i = 1, #ActiveCSARFrequencies
							do
								local FreqToRemove = ActiveCSARFrequencies[i]
									if
										FreqToRemove == ActiveFrequency
											then
												table.remove(ActiveCSARFrequencies, i)
											
									end
							end
						local ThirdFlagCheck = trigger.misc.getUserFlag(foundObjectsName.."CSARCount")
						--env.info("Completed Pickup Function")
				elseif PlayerCSARCount == 3
					then
						trigger.action.setUserFlag(foundObjectsName.."CSARCount", 4)
						trigger.action.outTextForGroup(foundObjectsName, "You have successfully picked up the pilot and your heli is now full! Return to the nearest NATO airbase or FARP to drop the pilots off and complete the CSAR missions!", 20, 1)
						trigger.action.deactivateGroup(PilotGroup)
						for i = 1, #ActiveCSARFrequencies
							do
								local FreqToRemove = ActiveCSARFrequencies[i]
									if
										FreqToRemove == ActiveFrequency
											then
												table.remove(ActiveCSARFrequencies, i)
											
									end
							end
						local FourthFlagCheck = trigger.misc.getUserFlag(foundObjectsName.."CSARCount")
						--env.info("Completed Pickup Function")
				elseif PlayerCSARCount > 3
					then
						trigger.action.outTextForGroup(foundObjectsName, "Your heli is already full! You must return to base before collecting any more pilots!", 20, 1)
				end
		else
			--env.info("CSAR Found nothing, returning 30")
			return timer.getTime() + 30
	end
end

function ifFoundUnit(foundItem, val)
	if foundItem:hasAttribute("Helicopters") and foundItem:getPlayerName() ~= nil and foundItem:inAir() == false
		then
			val[#val + 1] = foundItem:getGroup():getID()
	end
end

function CSARDropoff:onEvent(event)
	if event.initiator == nil
		then
			--env.info("Event Initiator was Nil")
	elseif (event.id == world.event.S_EVENT_LAND and event.place:getTypeName() == "Kobuleti" and event.initiator:getPlayerName() ~= nil) or (event.id == world.event.S_EVENT_LAND and event.place:getTypeName() == "Batumi" and event.initiator:getPlayerName() ~= nil) 
		or (event.id == world.event.S_EVENT_LAND and event.place:getTypeName() == "Stennis - airbase" and event.initiator:getPlayerName() ~= nil) or (event.id == world.event.S_EVENT_LAND and event.place:getTypeName() == "LHA_Tarawa - airbase" and event.initiator:getPlayerName() ~= nil) 
		or (event.id == world.event.S_EVENT_LAND and string.find(event.place:getName(), "FARP") and event.initiator:getPlayerName() ~= nil)
		then
			--env.info("Entered CSAR Dropoff function")
			CheckCSARonBoard = trigger.misc.getUserFlag(event.initiator:getGroup():getID().."CSARCount")
				if CheckCSARonBoard > 0
					then
						--env.info("Running CSAR Dropoff Changes")
						LivesRemaining = LivesRemaining + CheckCSARonBoard
						LivesMIA = LivesMIA - CheckCSARonBoard
						trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "You have successfully returned "..CheckCSARonBoard.." pilots to base! Remaining lives have been adjusted.", 30, 1)
						CheckCSARonBoard = 0
						trigger.action.setUserFlag(event.initiator:getGroup():getID().."CSARCount", 0)
						--env.info("Finished Dropoff Changes")
				end
	end
end

-- F10 Menu Additions --
PlayerGroupIDs = {}

function F10MenuOptions:onEvent(event)
    if event.id == world.event.S_EVENT_BIRTH and event.initiator and event.initiator:getPlayerName() ~= nil 
		then
			local PlayerID = event.initiator:getGroup():getID()
			if PlayerGroupIDs[PlayerID] == nil then
				PlayerGroupIDs[PlayerID] = true
				missionCommands.addCommandForGroup(PlayerID, "Team Lives Status", nil, PrintLives, PlayerID)
				missionCommands.addCommandForGroup(PlayerID, "Active CSAR Frequencies", nil, PrintCSARFrequencies, PlayerID)
        end
    end
end

function PrintLives(Player)
	trigger.action.outTextForGroup(Player, "Operation Storm Eagle II Lives Status \n\nLives Remaining: " ..LivesRemaining.. " \nAirborne Pilots: " ..LivesAirborne.. "\nPilots MIA: " ..LivesMIA.. "\nLives Lost: " ..LivesLost, 10, 1)
end

function PrintCSARFrequencies(Player)
	if #ActiveCSARFrequencies < 1
		then
			trigger.action.outTextForGroup(Player, "There are currently no CSAR Missions available.", 10, 1)
	else
		trigger.action.outTextForGroup(Player, "Active CSAR Beacons\n" ..table.concat(ActiveCSARFrequencies, "\n"), 20, 1)
	end
end


world.addEventHandler(NewCSARMission)
world.addEventHandler(CSARDropoff)
world.addEventHandler(LivesEventHandler)
world.addEventHandler(F10MenuOptions)