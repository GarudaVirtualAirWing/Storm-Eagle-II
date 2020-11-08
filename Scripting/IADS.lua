local SAMRangeLookupTable = {

    ["Kub 1S91 str"] = 52000,

    ["S-300PS 40B6M tr"] =  100000,  

    ["Osa 9A33 ln"] = 25000,

    ["snr s-125 tr"] = 60000,  

    ["SNR_75V"] = 65000,

    ["Dog Ear radar"] = 26000,

    ["SA-11 Buk LN 9A310M1"] = 43000,

    ["Hawk tr"] = 60000,
    
    ["Tor 9A331"] = 100000,

}

local function getIndex(tab, val)
    local index = nil
    for i, v in ipairs(tab) do 
        if (v.id == val) then
          index = i 
        end
    end
    return index
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

local SAMSite = {}
local EWRSite = {}
local AEWAircraft = {}
local suppressedGroups = {}
local tracked_weapons = {}
SEADHandler = {}

local function TableConcat(t1,t2)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

local function tablelength(T)
  if T == nil then

    return 0

  end
  local count = 0
  for _ in pairs(T) do 

    count = count + 1         
  end
  return count
end

local function getDistance(point1, point2)

  local x1 = point1.x
  local y1 = point1.y
  local z1 = point1.z
  local x2 = point2.x
  local y2 = point2.y
  local z2 = point2.z
  local dX = math.abs(x1-x2)
  local dY = math.abs(y1-y2)
  local dZ = math.abs(z1-z2)
  local distance = math.sqrt(dX*dX + dZ*dZ)

  return distance

end

local function getDistance3D(point1, point2)

  local x1 = point1.x
  local y1 = point1.y
  local z1 = point1.z
  local x2 = point2.x
  local y2 = point2.y
  local z2 = point2.z

  local dX = math.abs(x1-x2)
  local dY = math.abs(y1-y2)
  local dZ = math.abs(z1-z2)
  local distance = math.sqrt(dX*dX + dZ*dZ + dY*dY)

  return distance

end

local function rangeOfSAM(gp)  
  
  local maxRange = 0 
  for i, unit in pairs(gp:getUnits()) do     
    if unit:hasAttribute("SAM TR") and SAMRangeLookupTable[unit:getTypeName()] then  
      local samRange  = SAMRangeLookupTable[unit:getTypeName()]
      if maxRange < samRange then         
        maxRange = samRange          
      end
    end
  end
    return maxRange  
end

local function disableSAM(disableArray)
  if disableArray[3] then
--    ----env.info("Emergency shutdown!")
    if SAMSite[disableArray[1]] then
    
      SAMSite[disableArray[1]].DisableTime = disableArray[2]
      SAMSite[disableArray[1]].EnableTime = nil
      SAMSite[disableArray[1]].Emitting = false
      SAMSite[disableArray[1]].SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
      if disableArray[2] then
      
--        ----env.info("SAM Site: "..SAMSite[disableArray[1]].Name.." disabled for "..disableArray[2].." seconds")
            
      else
      
--        ----env.info("SAM Site: "..SAMSite[disableArray[1]].Name.." disabled until instructed otherwise")
              
      end
    end
  else   
--    ----env.info("Non-emergency shutdown")
--    ----env.info(SAMSite[disableArray[1]].SAMGroup:getName().." is in the disable fcn")
    local detectedTargets = SAMSite[disableArray[1]].SAMGroup:getController():getDetectedTargets()
--    ----env.info("It has detected "..#detectedTargets.." units and will stay on")
    if disableArray[2] == nil then
 --     ----env.info("Disabling with no disable time")
      SAMSite[disableArray[1]].DisableTime = nil
      SAMSite[disableArray[1]].EnableTime = nil
      SAMSite[disableArray[1]].Emitting = false
      SAMSite[disableArray[1]].SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
--      ----env.info("SAM Site: "..SAMSite[disableArray[1]].Name.." disabled until further notice")    

    elseif (disableArray[2] > SAMSite[disableArray[1]].DisableTime) then
--      ----env.info("Disabling with disable time")
      SAMSite[disableArray[1]].DisableTime = disableArray[2]
      SAMSite[disableArray[1]].EnableTime = nil
      SAMSite[disableArray[1]].Emitting = false
      SAMSite[disableArray[1]].SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
--      ----env.info("SAM Site: "..SAMSite[disableArray[1]].Name.." disabled for "..disableArray[2].." seconds")    

    end
  end
end

local function enableSAM(enableArray)

  if SAMSite[enableArray[1]] and SAMSite[enableArray[1]].Hidden == false then
  
    SAMSite[enableArray[1]].Emitting = true
    SAMSite[enableArray[1]].EnableTime = enableArray[2]
    SAMSite[enableArray[1]].SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,2)
    if enableArray[2] then
    
--      ----env.info("SAM Site: "..SAMSite[enableArray[1]].Name.." enabled for: " ..enableArray[2].."s")
         
    else
    
--     ----env.info("SAM Site: "..SAMSite[enableArray[1]].Name.." enabled until further notice")
      
    end

  end
end

local function disableAllSAMs()

  for i, SAM in pairs(SAMSite) do
    local disableArray = {SAM.Name, nil, nil} 
    disableSAM(disableArray)

  end
end

local function enableUncontrolledSAMs()
  for i, SAM in pairs(SAMSite) do

    if tablelength(SAM.ControlledBy) == 0 then
      local enableArray = {SAM.Name, nil}
      enableSAM(enableArray)
--      --env.info(SAM.Name.." is uncontrolled and being activated")
    end
  end
end

local function associateSAMS()
  
  for j, SAM in pairs(SAMSite) do  
    SAM.ControlledBy = {}
  end
  for i, EWR in pairs(EWRSite) do
  EWR.SAMsControlled = {}
    for j, SAM in pairs(SAMSite) do
      if getDistance3D(SAM.Location, EWR.Location) < 80000 then
        
        EWR.SAMsControlled[SAM.Name] = SAM
        SAM.ControlledBy[EWR.Name] = EWR
        --env.info("EWR: "..EWR.Name.." is associated with SAM: "..SAM.Name)
        
      end
    end
  end   
end

local function populateLists()
  SAMSite = {}
  EWRSite = {}
  AEWAircraft = {}
  local isEWR = 0
  local isSAM = 0
  local samType
  local numSAMRadars = 0
  local numTrackRadars = 0
  local numEWRRadars = 0
  for i, gp in pairs(coalition.getGroups(1)) do

    if gp:getCategory() == 2 then

      for j, unt in pairs(gp:getUnits()) do

        if unt:hasAttribute("EWR") then

          isEWR = 1
          numEWRRadars = numEWRRadars + 1

        elseif unt:hasAttribute("SAM TR") or unt:hasAttribute("SAM SR") then

          isSAM = 1
          samType = unt:getTypeName()
          numSAMRadars = numSAMRadars + 1

        end
      end
      if isEWR == 1 then
        EWRSite[gp:getName()] = {

            ["Name"] = gp:getName(),
            ["EWRGroup"] = gp,
            ["SAMsControlled"] = {},
            ["DetectedUnits"] = {},
            ["Location"] = gp:getUnit(1):getPoint(),
            ["numEWRRadars"] = numEWRRadars

        }
--       ----env.info("EWR Registered, named: "..gp:getName())
        isEWR = 0  
        isSAM = 0
        numEWRRadars = 0
        numSAMRadars = 0

      elseif isSAM == 1 and rangeOfSAM(gp) then

        SAMSite[gp:getName()] = {

            ["Name"] = gp:getName(),
            ["SAMGroup"] = gp,
            ["Type"] = samType,
            ["Location"] = gp:getUnit(1):getPoint(),
            ["numSAMRadars"] = numSAMRadars,
            ["EngageRange"] = rangeOfSAM(gp),           
            ["ControlledBy"] = {}, 
            ["SuppressedTime"] = 0,
            ["Suppressed"] = false,
            ["Hidden"] = false,
            ["HiddenTime"] = 0,
            ["HideCountdown"] = 0,
            ["HideCountdownBool"] = false,
            ["EnableTime"] = 0,
            ["DisableTime"] = 0,
            ["SearchVolume"] =
            {
              id = world.VolumeType.SPHERE,
              params =
              {
                point =  gp:getUnit(1):getPoint(),
                raidus = rangeOfSAM(gp)
              }
            }
        }
        isEWR = 0  
        isSAM = 0
        numEWRRadars = 0
        numSAMRadars = 0

      end 
    end  
  end
  associateSAMS()
  --env.info("Lists Populated, there are "..tablelength(EWRSite).." EWR Sites, "..tablelength(SAMSite).." SAM Sites, and "..tablelength(AEWAircraft).." AEW Aircraft. SAM sites associated with IADS network.")
  return timer.getTime() + 600
end

local function suppress(suppArray)
  
  suppressedGroups[suppArray[1]:getName()] = {["SuppGroup"] = suppArray[1], ["SuppTime"] = suppArray[2]}
  suppArray[1]:getController():setOnOff(false)

end

local function unSuppress(unSuppGroup)
  
--  --env.info("Removing suppressed unit from group")
  unSuppGroup:getController():setOnOff(true)
  suppressedGroups[unSuppGroup:getName()] = nil
--  --env.info("Suppressed unit removed from group")

end

local function ifFoundK(foundItem, impactPoint)
--  --env.info("Found unit in kill range")
  local point1 = foundItem:getPoint()
  point1.y = point1.y + 2
  local point2 = impactPoint
  point2.y = point2.y + 2
  if land.isVisible(point1, point2) == true then
--    --env.info("Unit"..foundItem:getID().. "Destroyed by script")                         
    trigger.action.explosion(point1, 1)
  end                                                                    
end

local function ifFoundD(foundItem, impactPoint)
--  --env.info("Found static in kill range")
  local point1 = foundItem:getPoint()
  point1.y = point1.y + 2
  local point2 = impactPoint
  point2.y = point2.y + 2
  if land.isVisible(point1, point2) == true then
--    --env.info("Static"..foundItem:getID().. "Destroyed by script")                         
    trigger.action.explosion(point1, 10)
  end  
end

local function ifFoundS(foundItem, impactPoint)
--  --env.info("Found unit in suppression range")
  if foundItem:getGroup() and foundItem:getName() and foundItem:getGroup():getCategory() == 2 then
--    --env.info("Suppresing: "..foundItem:getName())
    local point1 = foundItem:getPoint()
    point1.y = point1.y + 5
    local point2 = impactPoint
    point2.y = point2.y + 5
    local suppTimer = math.random(35,100)
    local suppArray = {foundItem:getGroup(), suppTimer}
    if land.isVisible(point1, point2) == true then
      suppress(suppArray)
--      --env.info("Suppressing.")
    end  
  end
end

local function magnumHide(hiddenGroup)

    SAMSite[hiddenGroup:getName()].HideCountdownBool = true
    SAMSite[hiddenGroup:getName()].HideCountdown = math.random(15,25)
--    --env.info("Magnum Hide "..hiddenGroup:getName())  
end

local function track_wpns()
  for wpn_id_, wpnData in pairs(tracked_weapons) do

    if wpnData.wpn:isExist() then  -- just update position and direction.
      wpnData.pos = wpnData.wpn:getPosition().p
      wpnData.dir = wpnData.wpn:getPosition().x
      wpnData.exMass = wpnData.wpn:getDesc().warhead.explosiveMass
    else -- wpn no longer exists, must be dead.
--      --env.info("Weapon impacted, mass of weapon warhead is " .. wpnData.exMass)
      local suppressionRadius = wpnData.exMass
      local ip = land.getIP(wpnData.pos, wpnData.dir, 20)  -- terrain intersection point with weapon's nose.  Only search out 20 meters though.
      local impactPoint
      if not ip then -- use last position
        impactPoint = wpnData.pos
       -- trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
      else -- use intersection point
        impactPoint = ip
       -- trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
      end 
      local VolK =
        {
          id = world.VolumeType.SPHERE,
          params =
          {
            point = impactPoint,
            radius = suppressionRadius*0.2
          }
        }
     local VolD =
        {
          id = world.VolumeType.SPHERE,
          params =
          {
            point = impactPoint,
            radius = suppressionRadius*0.1
          }
        }
      local VolS =
        {
          id = world.VolumeType.SPHERE,
          params =
          {
            point = impactPoint,
            radius = suppressionRadius
          }
        }                              
--      --env.warning("Begin Search")
      world.searchObjects(Object.Category.UNIT, VolK, ifFoundK,impactPoint)
      world.searchObjects(Object.Category.STATIC, VolD, ifFoundD,impactPoint)
      world.searchObjects(Object.Category.UNIT, VolS, ifFoundS,impactPoint)               
--      --env.warning("Finished Search")
      tracked_weapons[wpn_id_] = nil -- remove from tracked weapons first.         
    end
  end
  return timer.getTime() + 1
end

function SEADHandler:onEvent(event)
  if event.id == world.event.S_EVENT_DEAD then
--  --env.info("Something died")
--  --env.info("A unit category is: " ..Object.Category.UNIT)
  if event.initiator:getCategory() == Object.Category.UNIT and event.initiator:getGroup() then
--    --env.info("It's a unit with a group, group is named: " ..event.initiator:getGroup():getName()) 
    local eventUnit = event.initiator  
    local eventGroup = event.initiator:getGroup()
    for i, SAM in pairs(SAMSite) do     
      if eventGroup:getName() == SAM.Name then
        --env.info("It was an SAM")
        if eventUnit:hasAttribute("SAM TR") or eventUnit:hasAttribute("SAM SR") then
          --env.info("Radar destroyed")
          SAM.numSAMRadars = SAM.numSAMRadars - 1
          --env.info("There are :" ..SAM.numSAMRadars .." left")         
        end  
        if SAM.numSAMRadars < 1 then
          --env.info("with no radars left")
          for j, EWR in pairs(EWRSite) do           
              for k, SAMControlled in pairs(EWR.SAMsControlled) do 
                --env.info(EWR.Name .. " / " ..SAMControlled.Name)             
                if SAMControlled.Name == SAM.Name then
                  SAMControlled = nil
                  --env.info("EWR/SAM association removed between " ..SAM.Name.." and " ..EWR.Name)
                end              
              end          
          end
          SAMSite[SAM.Name] = nil
          --env.info("Removed from list")          
        end
      end
    end 
    for i, EWR in pairs(EWRSite) do    
      if eventGroup:getName() == EWR.Name then
        if eventUnit:hasAttribute("EWR") then
          --env.info("It was an EWR")
          EWR.numEWRRadars = EWR.numEWRRadars - 1
          --env.info("Number of radar units remaining: " ..EWR.numEWRRadars)
          if EWR.numEWRRadars < 1 then      
            --env.info("with no radars left")
            for j, SAM in pairs(SAMSite) do              
              for k, controllingEWR in pairs(SAM.ControlledBy) do              
                if controllingEWR.Name == EWR.Name then                
                  controllingEWR = nil
                  --env.info("EWR: " ..EWR.Name.. "is no longer assoicated with SAM: "..SAM.Name)                
                end              
              end            
            end
            EWRSite[EWR.Name] = nil              
            --env.info("Removed from list") 
          end
        end
      enableUncontrolledSAMs()
      end
    end   
  end  
  elseif event.id == world.event.S_EVENT_SHOT then
    if event.weapon then
--  --env.info("Something has been launched")
--  --env.info("Desc is: ".. table.tostring(Weapon.getDesc(event.weapon)))
      local ordnance = event.weapon                  
      local ordnanceName = ordnance:getTypeName()
      local WeaponPoint = ordnance:getPoint()
      local WeaponDesc = event.weapon:getDesc()
      local init = event.initiator
      if (WeaponDesc.category == 3 or WeaponDesc.category == 2 or WeaponDesc.category == 1) and not (WeaponDesc.missileCategory == 1 or WeaponDesc.missileCategory == 2 or WeaponDesc.missileCategory == 3) then
        if WeaponDesc.guidance == 5 then
--         --env.info("Is ARM")
          for i, SAM in pairs(SAMSite) do        
            if math.random(1,100) > 10 and getDistance(SAM.Location, WeaponPoint) < 120000 then   
              if SAM.Type ~= "Tor 9A331" then
                 magnumHide(SAM.SAMGroup)
              end
            end     
          end
        end
        tracked_weapons[event.weapon.id_] = { wpn = ordnance, init = init:getName(), pos = WeaponPoint,}
--        --env.info("Weapon is a: " .. ordnanceName)                                                          
      end
    end
  end
end


local function IADSMonitor()
  ----env.info("IADS Start")
  -- CHECK SUPPRESSION
  for i, suppGroup in pairs(suppressedGroups)  do 
    if suppGroup.SuppTime and suppGroup.SuppGroup then
      if suppGroup.SuppTime < 1 then      
        unSuppress(suppGroup.SuppGroup)      
      else     
        suppGroup.SuppTime = suppGroup.SuppTime - 1  
      end
    end 
  end  
  for i, SAM in pairs(SAMSite) do
    if SAM.SAMGroup:isExist()  then     
      if SAM.HideCountdownBool then 
        if SAM.HideCountdown < 1 then          
          local disableArray = {SAM.Name, nil, true}
          SAM.HideCountdownBool = false
          SAM.Hidden = true
          SAM.HiddenTime = math.random(65,100)
          disableSAM(disableArray)        
        else        
          SAM.HideCountdown = SAM.HideCountdown - 1         
        end      
      elseif SAM.Hidden then    
        if SAM.HiddenTime < 1 then        
          local enableArray = {SAM.Name, 120}
          SAM.Hidden = false
          enableSAM(enableArray)        
        else       
          SAM.HiddenTime = SAM.HiddenTime - 1
        end   
      end  
      if SAM.EnableTime and SAM.EnableTime < 1 and SAM.Hidden == false and SAM.Emitting then        
        local disableArray = {SAM.Name, nil, nil} 
        disableSAM(disableArray)      
      elseif SAM.EnableTime and SAM.Emitting then      
        SAM.EnableTime = SAM.EnableTime - 1 
      end      
      if SAM.DisableTime and SAM.DisableTime < 1 and SAM.Emitting == false then      
        local enableArray = {SAM.Name, 120}
        enableSAM(enableArray)     
      elseif SAM.DisableTime and SAM.Emitting == false then      
        SAM.DisableTime = SAM.DisableTime - 1         
      end      
    end
   end
  -- DETECT UNITS and ACTIVATE
  for i, EWR in pairs(EWRSite) do
    if EWR.EWRGroup:isExist() then
      EWR.DetectedUnits = {}
      if EWR.EWRGroup:getController() then
        EWR.DetectedUnits = EWR.EWRGroup:getController():getDetectedTargets(Controller.Detection.RADAR)
        for j, detectedTarget in pairs(EWR.DetectedUnits) do
          if detectedTarget.object and (detectedTarget.object:getCategory() == 1) and detectedTarget.object:getGroup() and detectedTarget.object:getGroup():getUnit(1):getPoint() and detectedTarget.object:getGroup():getUnit(1) and detectedTarget.object:inAir() then
            for k, SAM in pairs(EWR.SAMsControlled) do
              local rangeToSAM = getDistance(detectedTarget.object:getPoint(),SAM.Location)
              if rangeToSAM < SAM.EngageRange then 
                local enableArray = {SAM.Name, 180}
                enableSAM(enableArray)              
              end
            end 
          end
        end  
      end 
    end  
  end     
  ----env.info("IADS Monitor complete")
  return timer.getTime() + 1
end

populateLists()
timer.scheduleFunction(track_wpns, {}, timer.getTime() + 1)
--env.info("Populated SAM, AEW and EWR lists")
disableAllSAMs()
enableUncontrolledSAMs()
--env.info("Uncontrolled SAMs enabled")
--env.info("Weapon tracking begun")
timer.scheduleFunction(IADSMonitor,{},timer.getTime()+1)
--env.info("IADS monitoring begun")
world.addEventHandler(SEADHandler)
--env.info("SEAD event handler initiated")