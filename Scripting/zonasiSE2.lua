Zone1Zone = ZONE:FindByName( "Senaki Zone" )
Zone1CaptureZone = ZONE_CAPTURE_COALITION:New( Zone1Zone, coalition.side.RED )

Zone2Zone = ZONE:FindByName( "Zugdidi City" )
Zone2CaptureZone = ZONE_CAPTURE_COALITION:New( Zone2Zone, coalition.side.RED )

Zone3Zone = ZONE:FindByName( "Khashuri City" )
Zone3CaptureZone = ZONE_CAPTURE_COALITION:New( Zone2Zone, coalition.side.RED )

-- zonasi zone 1 start ---
--- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
function Zone1CaptureZone:OnEnterGuarded( From, Event, To )
  if From ~= To then
    local Coalition = self:GetCoalition()
    self:E( { Coalition = Coalition } )
    if Coalition == coalition.side.BLUE then
	Zone1CaptureZone:Smoke( SMOKECOLOR.Blue )
  trigger.action.outText("GARUDA Air Wing protecting Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    else
	Zone1CaptureZone:Smoke( SMOKECOLOR.Red )
  trigger.action.outText("Georgian Insurgency Army protecting Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    end
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone1CaptureZone:OnEnterAttacked()
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    trigger.action.outText("Georgian Insurgency Army attacking Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
  Zone1CaptureZone:Smoke( SMOKECOLOR.White )
    trigger.action.outText("GARUDA Air Wing attacking Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone1CaptureZone:OnEnterCaptured()
  trigger.action.outSound("walkietalkie2.ogg" )
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
  trigger.action.outText("GARUDA Air Wing captured Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
    trigger.action.outText("Georgian Insurgency Army captured Senaki Airbase", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
   
  self:__Guard( 30 )
end

Zone1CaptureZone:__Guard( 1 )
Zone1CaptureZone:Start( 30, 120 )

-- zonasi zone 1 end ---

-- zonasi zone 2 start ---

--- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
function Zone2CaptureZone:OnEnterGuarded( From, Event, To )
  if From ~= To then
    local Coalition = self:GetCoalition()
    self:E( { Coalition = Coalition } )
    if Coalition == coalition.side.BLUE then
	Zone2CaptureZone:Smoke( SMOKECOLOR.Blue )
  trigger.action.outText("GARUDA Air Wing protecting Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    else
	Zone2CaptureZone:Smoke( SMOKECOLOR.Red )
  trigger.action.outText("Georgian Insurgency Army protecting Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    end
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone2CaptureZone:OnEnterAttacked()
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    trigger.action.outText("Georgian Insurgency Army attacking Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
  
    trigger.action.outText("GARUDA Air Wing attacking Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone2CaptureZone:OnEnterCaptured()
  trigger.action.outSound("walkietalkie2.ogg" )
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    trigger.action.outText("GARUDA Air Wing captured Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
    trigger.action.outText("Georgian Insurgency Army captured Zugdidi City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
   
  self:__Guard( 30 )
end

Zone2CaptureZone:__Guard( 1 )
Zone2CaptureZone:Start( 30, 120 )

-- zonasi zone 2 end ---

-- zonasi zone 3 start ---
--- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
function Zone3CaptureZone:OnEnterGuarded( From, Event, To )
  if From ~= To then
    local Coalition = self:GetCoalition()
    self:E( { Coalition = Coalition } )
    if Coalition == coalition.side.BLUE then
	Zone1CaptureZone:Smoke( SMOKECOLOR.Blue )
  trigger.action.outText("GARUDA Air Wing protecting Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    else
	Zone1CaptureZone:Smoke( SMOKECOLOR.Red )
  trigger.action.outText("Georgian Insurgency Army protecting Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
    end
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone3CaptureZone:OnEnterAttacked()
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    trigger.action.outText("Georgian Insurgency Army attacking Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
  Zone1CaptureZone:Smoke( SMOKECOLOR.White )
    trigger.action.outText("GARUDA Air Wing attacking Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function Zone3CaptureZone:OnEnterCaptured()
  trigger.action.outSound("walkietalkie2.ogg" )
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
  trigger.action.outText("GARUDA Air Wing captured Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  else
    trigger.action.outText("Georgian Insurgency Army captured Khashuri City", 10 , false)
  trigger.action.outSound("walkietalkie.ogg" )
  end
   
  self:__Guard( 30 )
end

Zone1CaptureZone:__Guard( 1 )
Zone1CaptureZone:Start( 30, 120 )

-- zonasi zone 3 end ---