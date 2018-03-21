local appName = "Assist Gyroempf. der 3 Achsen"
local version = "1.00";
local controls = system.getDeviceType() == "JETI DC-24" and 10 or 4
local enable, switch, poti
local ctrl1, ctrl2, ctrl3
local channel1, channel2, channel3
local lastG1, lastG2, lastG3
local lastE, lastS

local function initForm(subform)
	form.addRow(2)
  form.addLabel({label="Deaktivierungsschalter", width=240})  
  form.addInputbox(enable, true, function(value)
		enable=value
		system.pSave("enable",value) 
  end)
  form.addRow(2)
  form.addLabel({label="3-Stufen-Schalter", width=240})  
  form.addInputbox(switch, true, function(value)
		switch=value
		system.pSave("switch",value) 
  end)
  form.addRow(2)
  form.addLabel({label="POTI", width=240})  
  form.addInputbox(poti, true, function(value)
		poti=value
		system.pSave("poti",value) 
  end) 	
	form.addRow(2)
  form.addLabel({label="Gyro Geber 1 (Quer)", width=160})
	form.addIntbox(channel1, 1, controls, 1, 0, 1, function(value)
		channel1=value
		system.pSave("channel1",value)
	end)
	form.addRow(2)
  form.addLabel({label="Gyro Geber 2 (Höhe)", width=160})
	form.addIntbox(channel2, 1, controls, 2, 0, 1, function(value)
		channel2=value
		system.pSave("channel2",value)
	end)
	form.addRow(2)
  form.addLabel({label="Gyro Geber 3 (Seite)", width=160})
	form.addIntbox (channel3, 1, controls, 3, 0, 1, function(value)
		channel3=value
		system.pSave("channel3",value)
	end)
	form.addRow(1)
	form.addLabel({label="Powered by Thorn for Rainer - v."..version,font=FONT_MINI, alignRight=true})
end

local function keyPressed(key)
	if (key == KEY_5) then
		if (ctrl1) then
			system.unregisterControl(ctrl1)
		end
		if (ctrl2) then
			system.unregisterControl(ctrl2)
		end
		if (ctrl3) then
			system.unregisterControl(ctrl3)
		end
		if (channel1) then			
			ctrl1 = system.registerControl(channel1, "Gyro-Empfindlichkeit 1", "G1")
		end
		if (channel2) then			
			ctrl2 = system.registerControl(channel2, "Gyro-Empfindlichkeit 2", "G2")
		end
		if (channel3) then			
			ctrl3 = system.registerControl(channel3, "Gyro-Empfindlichkeit 3", "G3")
		end
	end
end

-- Init function
local function init() 
	enable = system.pLoad("enable")
  switch = system.pLoad("switch")
  poti = system.pLoad("poti")
	
	channel1 = system.pLoad("channel1", 1)
	channel2 = system.pLoad("channel2", 2)
	channel3 = system.pLoad("channel3", 3)
	
	lastG1 = tonumber(system.pLoad("lastG1", 0))
	lastG2 = tonumber(system.pLoad("lastG2", 0))
	lastG3 = tonumber(system.pLoad("lastG3", 0))
	
	ctrl1 = system.registerControl(channel1, "Gyro-Empfindlichkeit 1", "G1")
	ctrl2 = system.registerControl(channel2, "Gyro-Empfindlichkeit 2", "G2")
	ctrl3 = system.registerControl(channel3, "Gyro-Empfindlichkeit 3", "G3")
	
	system.setControl(ctrl1, lastG1, 0, 0)
	system.setControl(ctrl2, lastG2, 0, 0)
	system.setControl(ctrl3, lastG3, 0, 0)
	
	system.registerForm(1,MENU_ADVANCED,appName,initForm,keyPressed)
end

-- Loop function
local function loop()
	local valE = system.getInputsVal(enable) 
  local valS = system.getInputsVal(switch)
  local valP = system.getInputsVal(poti)
  
	if (valE == 1) then
		lastE = true
	elseif (valS and valP) then	
		if (lastE or not lastS or lastS ~= valS) then
			local value	= 0
			
			if (valS == -1) then
				value = lastG1
			elseif (valS == 0) then
				value = lastG2
			elseif (valS == 1) then
				value = lastG3
			end
			
			if (math.abs(valP - value) > 0.04) then
				return
			end
			
			system.playBeep(0, 4000, 250)
		end
	
		if (valS == -1) then
			lastG1 = valP
			system.pSave("lastG1", tostring(lastG1))
			system.setControl(ctrl1, lastG1, 0, 0)
		elseif (valS == 0) then
			lastG2 = valP
			system.pSave("lastG2", tostring(lastG2))
			system.setControl(ctrl2, lastG2, 0, 0)
		elseif (valS == 1) then
			lastG3 = valP
			system.pSave("lastG3", tostring(lastG3))
			system.setControl(ctrl3, lastG3, 0, 0)
		end
		
		lastE = nil
		lastS = valS
	end
end

return {init=init, loop=loop, author="Thorn fuers JetiForum.de", version=version,name=appName}