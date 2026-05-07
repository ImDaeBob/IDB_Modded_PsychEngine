-- Script made by [ImDaeBob] for quick time skipping!!
-- To use, enter any song and press F1.
-- To quickly skip to previous time frame that you skipped too, press F2 without needing to use F1.

-- [=====================================================]
-- F1 - Open/Close State [✅]
-- F2 x2 - Time jump
-- F3 - Save timestamp to memory [✅]
-- F4 - Continue song behind
-- F5 - Toggle between live time and saved timestamp [✅]
-- F6 - Quick toggle botplay [✅]
-- F7 - Fun fact!
-- F8 - Change BG [✅]
-- F9 - Toggle Particle System [✅]
-- F10 - Reset preferences (From F8 - F9)
-- F11 - Firework I guess
-- F12 - Leave song lel [✅]
-- [=====================================================]

function onCreate()
	runHaxeCode([[
		import flixel.addons.display.FlxBackdrop;
		import flixel.addons.display.FlxGridOverlay;
	]])
end

function onStartCountdown()	
	if not allowCountdown then
		return Function_Stop;
	end
	return Function_Continue;
end

---------------------------------------- Values Board
local BGOpacity = 50;
local Multiplier = 1;

---------------------------------------- Miscs & Data Handlers
local disScreen = false; 
local transitioning = false;

local tempFile;
local tempFPath = ""; -- Auto pathfinding lol
local liveTime = true;

local BGtype = 1;
local BGGroup = {}; -- Insane data handler if you ask me
-- For BGtype #3
local sMax = 50;
local sCount = 3;
local sTick = 0;
local sRate; -- Bases of BPM;

local pSystem = false;
local pCount = 1;
local pMax = 200;
local pRate; -- Bases of BPM;
local pTick = 0;
local pGroup = {};

local camGrp = {};
local textTag = {};
local selectable = {};
local _gSelectable = {};
local editedValue = {0, 0, 0};
local maxValue = {0, {0, 0}, 0};

local keyboardDict = {
	{'0', {'ZERO', 'NUMPADZERO'}},
	{'1', {'ONE', 'NUMPADONE'}},
	{'2', {'TWO', 'NUMPADTWO'}},
	{'3', {'THREE', 'NUMPADTHREE'}},
	{'4', {'FOUR', 'NUMPADFOUR'}},
	{'5', {'FIVE', 'NUMPADFIVE'}},
	{'6', {'SIX', 'NUMPADSIX'}},
	{'7', {'SEVEN', 'NUMPADSEVEN'}},
	{'8', {'EIGHT', 'NUMPADEIGHT'}},
	{'9', {'NINE', 'NUMPADNINE}'},
	{'.', {'PERIOD', 'NUMPADPERIOD'}}
}};

local bobiExist = true; --[!!!]--
local bobiOffset = {};
local animCooldown = true;
local uPressedMe = true;
local tick = 0;

function onCreatePost()
	-- setProperty('dad.alpha', 0)
	-- setProperty('boyfriend.alpha', 0)
	
	for i, s in ipairs(getRunningScripts()) do
		if string.find(s, "skipTimer.lua") then
			tempFPath = s:sub(0, #s - 13).."timeskip.ftempt";
		end
	end	
			
	makeLuaSprite('BlackBGOverlay', '', 0, 0)
	makeGraphic('BlackBGOverlay', screenWidth, screenHeight, '7F7F7F')
	setObjectCamera('BlackBGOverlay', 'camOther')
	addLuaSprite('BlackBGOverlay')
	
	makeLuaSprite('Selector', '', -1, -1)
	makeGraphic('Selector', 1, 1, 'FFFFFF')
	setObjectCamera('Selector', 'camOther')
	addLuaSprite('Selector', true)
	
	-- BG 1
	backdropSpeed = bpm/4;
	runHaxeCode([[	
		public var gridDrop:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		gridDrop.velocity.set(]]..getDirection(backdropSpeed)..[[, ]]..getDirection(backdropSpeed)..[[);
		add(gridDrop);
		
		gridDrop.cameras = [camOther];
		game.setOnLuas("backdropped", true);
	]])
	if BGtype ~= 1 then
		runHaxeCode([[gridDrop.alpha = 0;]])
	end
	gAdd({'gridDrop'}, BGGroup)
	
	-- BG 2
	makeLuaSprite('BG2_S1', '', 0, 0)
	makeGraphic('BG2_S1', screenHeight, screenHeight, '000000')
	setObjectCamera('BG2_S1', 'camOther')
	setProperty('BG2_S1.alpha', 0.25)
	setProperty('BG2_S1.x', -getProperty('BG2_S1.width')/2)
	screenCenter('BG2_S1', 'Y')
	addLuaSprite('BG2_S1')
	
	makeLuaSprite('BG2_S3', '', 0, 0)
	makeGraphic('BG2_S3', screenHeight, screenHeight, '000000')
	setObjectCamera('BG2_S3', 'camOther')
	setProperty('BG2_S3.alpha', 0.25)
	setProperty('BG2_S3.x', screenWidth - getProperty('BG2_S3.width')/2)
	screenCenter('BG2_S3', 'Y')
	addLuaSprite('BG2_S3')
	
	makeLuaSprite('BG2_S2', '', 0, 0)
	makeGraphic('BG2_S2', screenHeight/1.5, screenHeight/1.5, '000000')
	setObjectCamera('BG2_S2', 'camOther')
	setProperty('BG2_S2.alpha', 0.1)
	screenCenter('BG2_S2')
	addLuaSprite('BG2_S2')

	gAdd({
		{'BG2_S1', getProperty('BG2_S1.alpha'), getAngleDirection(bpm/getRandomInt(10, 20))}, 
		{'BG2_S2', getProperty('BG2_S2.alpha'), getAngleDirection(bpm/getRandomInt(10, 20))}, 
		{'BG2_S3', getProperty('BG2_S3.alpha'), getAngleDirection(bpm/getRandomInt(10, 20))}},
	BGGroup)
	if BGtype ~= 2 then
		for i, obj in ipairs(BGGroup[2]) do
			setProperty(obj[1]..'.alpha', 0)
		end
	end
	
	-- BG 3
	sRate = 75/bpm;
	gAdd({}, BGGroup)
	for i=1, sMax do
		makeLuaSprite('Square'..i, '', 0, 0)
		makeGraphic('Square'..i, getRandomInt(25, 150), getRandomInt(25, 150), 'FFFFFF')
		setObjectCamera('Square'..i, 'camOther')
		if i < sCount then
			setProperty('Square'..i..'.alpha', getRandomFloat(0.1, 0.5))
		else
			setProperty('Square'..i..'.alpha', 0)
		end
		addLuaSprite('Square'..i)
		setProperty('Square'..i..'.x', getRandomInt(0, screenWidth - getProperty('Square'..i..'.width')))
		setProperty('Square'..i..'.y', getRandomInt(0, screenHeight - getProperty('Square'..i..'.height')))
		gAdd({'Square'..i, getProperty('Square'..i..'.alpha'), bpm/getRandomInt(5, 20), true}, BGGroup[3])
	end
	if BGtype ~= 3 then
		for i, obj in ipairs(BGGroup[3]) do
			setProperty(obj[1]..'.alpha', 0)
		end
	end
	
	-- for i=#BGGroup, 1, -1 do
		-- debugPrint(BGGroup[i])
	-- end
	
	-- Particle System
	pRate = 5/bpm;
	for i=1, pMax do
		gAdd({'', 0}, pGroup);
	end
----------------------------------------------------------------------------------------------------------------------------------------------------------
	--Text Tag #1
	makeAlphabet('BG Opacity: ', 'bold', 0.5, 10, screenHeight, 'b', '', false)
	makeText('Opacity', BGOpacity..'%', 0.5, 100, getProperty(textTag[#textTag][#textTag[#textTag]]..'.x') + getProperty(textTag[#textTag][#textTag[#textTag]]..'.width')/2, screenHeight - 42, 'center')
	gAdd('Opacity', selectable)
	
	--Text Tag #2
	makeAlphabet('Press Ctrl to change scroll speed', 'normal', 0.4, screenWidth - 4, 35, 'b', 'r', false)
	
	--Text Tag #3
	makeAlphabet('Multiplier: ', 'bold', 0.5, screenWidth - 80, 45, 't', 'r', false)
	makeText('Mult', Multiplier..'x', 0.5, 75, getProperty(textTag[#textTag][#textTag[#textTag]]..'.x') + 10, 40, 'center')
	gAdd('Mult', selectable)
	
	--Text Tag #4
	makeAlphabet('F1 to Leave or Enter this Screen', 'normal', 0.5, 10, 40, 'b', '', false)
	--Text Tag #5
	makeAlphabet('F2 (in this screen) to jump', 'normal', 0.5, 10, 80, 'b', '', false)
	--Text Tag #6
	makeAlphabet('F2 (outside this screen) to jump with saved timeskip', 'normal', 0.5, 10, 120, 'b', '', false)
	--Text Tag #7
	makeAlphabet('F3 save timeskip in memory', 'normal', 0.5, 10, 160, 'b', '', false)

	--Text Tag #8
	makeAlphabet('Use MOUSE and HOVER what value and SCROLL to change', 'normal', 0.4, screenWidth - 4, screenHeight - 145, 'b', 'r', false)
	--Text Tag #9
	makeAlphabet('OR', 'normal', 0.4, screenWidth - 4, screenHeight - 110, 'b', 'r', false)
	--Text Tag #10
	makeAlphabet('Use LEFT CLICK to select a value to change', 'normal', 0.4, screenWidth - 4, screenHeight - 75, 'b', 'r', false)
	--Text Tag #11
	makeAlphabet('Press ACCEPT to confirm your change', 'normal', 0.4, screenWidth - 4, screenHeight - 40, 'b', 'r', false)
	--Text Tag #12
	makeAlphabet('Press BACK to cancel your change', 'normal', 0.4, screenWidth - 4, screenHeight - 5, 'b', 'r', false)
	
	--Text Tag #13
	makeAlphabet('[JUMP TO]', 'bold', 1, screenWidth/2, screenHeight/2-70, 'b', 'c', false)
	
	-- [============]
	-- For Steps
	maxValue[1] = math.floor((songLength/1000*bpm*4)/60);
	
	-- For Time
	makeMin = songLength/1000/60; makeSec = 60 * makeMin - 60;
	maxValue[2] = {math.floor(makeMin), math.floor(makeSec)};
	
	-- For Seconds
	maxValue[3] = songLength/1000
	-- [============]
	
	--Text Tag #14
	makeAlphabet('<Time>', 'bold', 0.8, screenWidth/2.025, screenHeight/1.75, 'b', 'c', false)
	makeText('Time', maxValue[2][1]..':'..maxValue[2][2], 0.7, 200, 0, getProperty(textTag[#textTag][#textTag[#textTag]]..'.y') + getProperty(textTag[#textTag][#textTag[#textTag]]..'.height') + 10, 'center')
	setProperty('Time.x', screenWidth/2.025 - getProperty('Time.width')/2)
	gAdd('Time', selectable)
	
	--Text Tag #15
	makeAlphabet('~', 'bold', 0.75, screenWidth/1.6, screenHeight/1.915, 'c', 'c', false)
	
	--Text Tag #16
	makeAlphabet('<Seconds>', 'bold', 0.8, screenWidth/1.25, screenHeight/1.75, 'b', 'c', false)
	makeText('Seconds', maxValue[3], 0.7, 250, 0, getProperty(textTag[#textTag-2][#textTag[#textTag-2]]..'.y') + getProperty(textTag[#textTag-2][#textTag[#textTag-2]]..'.height') + 10, 'center')
	setProperty('Seconds.x', screenWidth/1.25 - getProperty('Seconds.width')/2)
	gAdd('Seconds', selectable)
	
	--Text Tag #17
	makeAlphabet('~', 'bold', 0.75, screenWidth/2.8, screenHeight/1.915, 'c', 'c', false)
	
	--Text Tag #18
	makeAlphabet('<Steps>', 'bold', 0.8, screenWidth/5, screenHeight/1.75, 'b', 'c', false)
	makeText('Steps', maxValue[1], 0.7, 200, 0, getProperty(textTag[#textTag-2][#textTag[#textTag-2]]..'.y') + getProperty(textTag[#textTag-2][#textTag[#textTag-2]]..'.height') + 10, 'center')
	setProperty('Steps.x', screenWidth/5 - getProperty('Steps.width')/2)
	gAdd('Steps', selectable)
	
	gAdd({getProperty('Steps.x'), getProperty('Steps.y')}, _gSelectable)
	gAdd({getProperty('Time.x'), getProperty('Time.y')}, _gSelectable)
	gAdd({getProperty('Seconds.x'), getProperty('Seconds.y')}, _gSelectable)
	
	matchBox('Time')
		
	makeAnimatedLuaSprite('Bobi', 'Bobi', 115, screenHeight/1.3)
	addAnimationByPrefix('Bobi', 'Idle', 'BobiIdleTablet', 1, false)
	gAdd({'Idle', 0, 0}, bobiOffset);
	addAnimationByPrefix('Bobi', 'Hi', 'BobiEnter', 26, false)
	gAdd({'Hi', 91, 206}, bobiOffset);
	addAnimationByPrefix('Bobi', 'SeHi', 'BobiTabletPull0', 28, false)
	gAdd({'SeHi', 14, 0}, bobiOffset);
	addAnimationByPrefix('Bobi', 'Looky', 'BobiLookAround', 24, false)
	gAdd({'Looky', 0, 1}, bobiOffset);
	addAnimationByPrefix('Bobi', 'Wassap', 'BobiWave', 24, false)
	gAdd({'Wassap', -1, 2}, bobiOffset);
	addAnimationByPrefix('Bobi', 'Reading', 'BobiRead', 24, false)
	gAdd({'Reading', 0, 0}, bobiOffset);
	addAnimationByPrefix('Bobi', 'PreBye', 'BobiTabletPullOut', 28, false)
	gAdd({'PreBye', 14, 0}, bobiOffset);
	addAnimationByPrefix('Bobi', 'Bye', 'BobiLeave', 26, false)
	gAdd({'Bye', 91, 206}, bobiOffset);
	if getProperty('Bobi.animation.curAnim.name') ~= 'Bye' then
		setProperty('Bobi.visible', false)
		bobiExist = false;
		
		makeText('CRUELTY', 'YOU ARE SO MEAN!! >:(', 0.4, 400, 0, screenHeight/1.3, 'center')
		setProperty('CRUELTY.color', getColorFromHex('FF0000'))
		setProperty('CRUELTY.angle', getRandomInt(-25, 25))
	end
	setObjectCamera('Bobi', 'camOther')
	addLuaSprite('Bobi', true)
	gAdd('Bobi', camGrp)
	
	-- makeLuaSprite('HitBox', '', getProperty('Bobi.x'), getProperty('Bobi.y'))
	-- makeGraphic('HitBox', getProperty('Bobi.width')/3, getProperty('Bobi.height')/2.75, '000000')
	-- setObjectCamera('HitBox', 'camOther')
	-- setObjectOrder('HitBox', getObjectOrder('Bobi'))
	-- addLuaSprite('HitBox', true)
	
	if not disScreen then
		setProperty('BlackBGOverlay.alpha', 0)
		runHaxeCode([[gridDrop.alpha = 0;]])
		setProperty('Selector.alpha', 0)
		setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
		for i, o in ipairs(camGrp) do
			setProperty(o..'.alpha', 0)
		end
		for i, type in ipairs(BGGroup) do
			if i > 1 then
				for j, content in ipairs(type) do
					setProperty(content[1]..'.alpha', 0)
				end
			end
		end
	else
		summonBobi();
		setProperty('camHUD.alpha', 0)
		setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
	end
	
	--Text Tag ###
	makeAlphabet('Press F1 to open Time Jump Screen', 'normal', 0.5, 10, 40, 'b', '', false)
	for i=1, #textTag[#textTag] do
		setProperty(textTag[#textTag][i]..'.alpha', 0.0001)
	end
end

function onUpdate(elapsed) -- For Interactions
	if keyboardJustPressed("F1") and not transitioning then -- Open & Close
		transitioning = true;
		
		if disScreen then
			disScreen = false;
						
			setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
			if BGtype == 1 then
				runHaxeCode([[FlxTween.tween(gridDrop, {alpha: 0}, 0.25);]])
			else
				for i, obj in ipairs(BGGroup[BGtype]) do
					doTweenAlpha(obj[1]..'Alpha', obj[1], 0, 0.25)
				end
			end
			doTweenAlpha('camHUDAlpha', 'camHUD', healthBarAlpha, 0.25)
			doTweenAlpha('SwitchState', 'BlackBGOverlay', 0, 0.25)
			doTweenAlpha('SelectorFade', 'Selector', 0, 0.15)
			for i, p in ipairs(pGroup) do
				if luaSpriteExists(p[1]) then
					cancelTween(p[1]..'Alpha')
					p[2] = getProperty(p[1]..'.alpha')
					doTweenAlpha(p[1]..'Alpha', p[1], 0, 0.25)
				end
			end
			for i, o in ipairs(camGrp) do
				doTweenAlpha(o..'Alpha', o, 0, 0.25)
			end
			for i, t in ipairs(textTag[#textTag]) do
				doTweenAlpha(t..'Alpha', t, 0.2, 0.35)
			end
		elseif not disScreen then
			disScreen = true;
			
			if getProperty('Bobi.animation.curAnim.name') == 'Bye' and bobiExist then
				runTimer('Summon', 0.5)
			end
			if not bobiExist then
				runTimer('YOUREMEAN', 0.5)
			end
			
			setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
			if BGtype == 1 then
				runHaxeCode([[FlxTween.tween(gridDrop, {alpha: 1}, 0.25);]])
			else
				for i, obj in ipairs(BGGroup[BGtype]) do
					doTweenAlpha(obj[1]..'Alpha', obj[1], obj[2], 0.25)
				end
			end
			doTweenAlpha('camHUDAlpha', 'camHUD', 0, 0.25)
			doTweenAlpha('SwitchState', 'BlackBGOverlay', BGOpacity/100, 0.25)
			for i, p in ipairs(pGroup) do
				if luaSpriteExists(p[1]) then
					cancelTween('sParticleX'..i)
					cancelTween('sParticleY'..i)
					cancelTween(p[1]..'Alpha')
					
					removeLuaText('sParticle'..i)
				end
			end
			for i, o in ipairs(camGrp) do
				doTweenAlpha(o..'Alpha', o, 1, 0.25)
			end
			for i, t in ipairs(textTag[#textTag]) do
				doTweenAlpha(t..'Alpha', t, 0, 0.25)
			end
		end
	end
	if keyboardJustPressed("F2") then		
		if disScreen then
			
		else

		end
	end
	if keyboardJustPressed("F3") and disScreen then -- Save timestamp
		unhideFile(tempFPath);
		tempFile, err = io.open(tempFPath, "w");
		if not tempFile then
			debugPrint(err)
		end
		tempFile:write(getTextString('Seconds'));
		tempFile:close();	
		hideFile(tempFPath)
		
		liveTime = false;
		for i=3, #selectable do
			setProperty(selectable[i]..'.color', getColorFromHex('99FF33'))
			doTweenColor(selectable[i]..'Color', selectable[i], 'FFFFFF', 0.5)
			
			setProperty(selectable[i]..'.scale.x', getProperty(selectable[i]..'.scale.x') + 0.25)
			setProperty(selectable[i]..'.scale.y', getProperty(selectable[i]..'.scale.y') + 0.25)
			doTweenX(selectable[i]..'XMod', selectable[i]..'.scale', 1, 1, 'elasticOut')
			doTweenY(selectable[i]..'YMod', selectable[i]..'.scale', 1, 1, 'elasticOut')
		end
	end
	if keyboardJustPressed("F5") and disScreen then -- Refresh timer to Current Time or to Saved Timeskip
		liveTime = not liveTime;
		
		if liveTime then			
			for i=3, #selectable do
				setProperty(selectable[i]..'.color', getColorFromHex('FF0000'))
				doTweenColor(selectable[i]..'Color', selectable[i], 'FFFFFF', 0.25)
				
				setProperty(selectable[i]..'.scale.y', -getProperty(selectable[i]..'.scale.y') - getRandomFloat(0.05, 0.15))
				doTweenY(selectable[i]..'YMod', selectable[i]..'.scale', 1, 0.25, 'backOut')
			end
		else
			tempFile = io.open(tempFPath, "r");
			setTime(tonumber(tempFile:read()));
			tempFile:close();
		
			for i=3, #selectable do
				setProperty(selectable[i]..'.color', getColorFromHex('FFFF00'))
				doTweenColor(selectable[i]..'Color', selectable[i], 'FFFFFF', 0.25)
				
				setProperty(selectable[i]..'.scale.x', -getProperty(selectable[i]..'.scale.x') - getRandomFloat(0.05, 0.15))
				doTweenX(selectable[i]..'XMod', selectable[i]..'.scale', 1, 0.25, 'backOut')
			end
		end		
	end
	if keyboardJustPressed("F6") and disScreen then -- Quick toggle Botplay
		setProperty('cpuControlled', not getProperty('cpuControlled'))
		setProperty('botplayTxt.visible', getProperty('cpuControlled'))
		setProperty('botplayTxt.alpha', getProperty('cpuControlled'))
		setProperty('botplaySine', 0)
		-- setProperty('changedDifficulty', true)
	end	
	if keyboardJustPressed("F8") and disScreen then -- Change BG
		BGtype = BGtype + 1;
		if BGtype > #BGGroup then
			BGtype = 1;
		end
		
		-- How tf did even thought of this?? Dis sht is optimized af!! And it works with no problem!!! :POG_FACE:
		if BGtype == 1 then
			runHaxeCode([[FlxTween.tween(gridDrop, {alpha: 1}, 0.15);]])
			for i, obj in ipairs(BGGroup[#BGGroup]) do
				doTweenAlpha(obj[1]..'Alpha', obj[1], 0, 0.15)
			end
		elseif BGtype == 2 then
			runHaxeCode([[FlxTween.tween(gridDrop, {alpha: 0}, 0.15);]])
		else
			for i, obj in ipairs(BGGroup[BGtype-1]) do
				doTweenAlpha(obj[1]..'Alpha', obj[1], 0, 0.15)
			end
		end
		for i, obj in ipairs(BGGroup[BGtype]) do
			doTweenAlpha(obj[1]..'Alpha', obj[1], obj[2], 0.15)
		end

	end
	if keyboardJustPressed("F9") and disScreen then -- Toggle Particle System
		pSystem = not pSystem;
	end
	if keyboardJustPressed("F12") and disScreen then -- Bruh...
		endSong();
	end
---------------------------------------------------------------------------------------------------------------------------------------------------------
	if disScreen then		
		getWheel = runHaxeCode([[FlxG.mouse.wheel]]);

		-- Selector Box --
		for i, s in ipairs(selectable) do
			if mX() >= getProperty(s..'.x') and mX() <= getProperty(s..'.x') + getProperty(s..'.width')
			and mY() >= getProperty(s..'.y') and mY() <= getProperty(s..'.y') + getProperty(s..'.height') then
				matchBox(s);
			end
		end
				
		-- Steps --
		if mouseInBox('Steps', '', 'Steps', '') and getWheel ~= 0 then
			liveTime = false;
			
			getSteps = tonumber(getTextString('Steps')) + getWheel * Multiplier;
			if getSteps < 0 then
				getSteps = maxValue[1];
			elseif getSteps > maxValue[1] then
				getSteps = 0;
			end
			
			setProperty('Steps.angle', getRandomInt(25, 35) * Multiplier/5 * getWheel)
			doTweenAngle('StepsAngle', 'Steps', 0, 0.15, 'backOut')
			
			setTime((getSteps*60)/(bpm*4));
		end

		-- Time --
		if mouseInBox('Time', '', 'Time', '') and getWheel ~= 0 then
			liveTime = false;
			
			getTimeString = getTextString('Time');
			makeMin = tonumber(getTimeString:sub(1, #getTimeString - 3));
			makeSec = tonumber(getTimeString:sub(#getTimeString - 1, #getTimeString));
			if mouseInBox('Time', '', 'Time', '', 2) then -- Mins
				makeMin = makeMin + Multiplier * getWheel;
				if makeMin < 0 then
					makeMin = 0;
				elseif makeMin > maxValue[2][1] then
					makeMin = maxValue[2][1];
				end
				if makeMin >= maxValue[2][1] and makeSec > maxValue[2][2] then
					makeSec = maxValue[2][2];
				end
			else -- Secs
				makeSec = makeSec + Multiplier * getWheel;
				if makeMin >= maxValue[2][1] then
					if makeSec < 0 then
						makeSec = maxValue[2][2];
					elseif makeSec > maxValue[2][2] then
						makeSec = 0;
					end
				else
					if makeSec < 0 then
						makeSec = 59;
					elseif makeSec > 59 then
						makeSec = 0;
					end
				end
			end
			
			setProperty('Time.scale.x', getProperty('Time.scale.x') + 0.075 * Multiplier * getWheel)
			doTweenX('TimeBouncyX', 'Time.scale', 1, 0.15, 'backOut')
			setProperty('Time.scale.y', getProperty('Time.scale.y') + 0.075 * Multiplier * getWheel)
			doTweenY('TimeBouncyY', 'Time.scale', 1, 0.15, 'backOut')
			
			setTime(makeMin * 60 + makeSec);
		end

		-- Seconds --
		if mouseInBox('Seconds', '', 'Seconds', '') and getWheel ~= 0 then
			liveTime = false;
			
			getSecs = tonumber(getTextString('Seconds')) + getWheel * Multiplier;
			if getSecs < 0 then
				getSecs = maxValue[3];
			elseif getSecs > maxValue[3] then
				getSecs = 0;
			end
			
			setProperty('Seconds.y', _gSelectable[3][2] - 5 * Multiplier * getWheel)
			doTweenY('SecondsY', 'Seconds', _gSelectable[3][2], 0.15, 'backOut')
			
			setTime(getSecs);
		end
		
		-- Multiplier --
		if keyboardJustPressed("CONTROL") then 
			Multiplier = Multiplier + 1;
			if Multiplier > 10 then
				Multiplier = 1;
			end
			
			setTextString('Mult', Multiplier..'x')
			setProperty('Mult.scale.x', getProperty('Mult.scale.x') + 0.2)
			doTweenX('MultBouncyX', 'Mult.scale', 1, 0.25, 'elasticOut')
			setProperty('Mult.scale.y', getProperty('Mult.scale.y') + 0.2)
			doTweenY('MultBouncyY', 'Mult.scale', 1, 0.25, 'elasticOut')
		elseif mouseInBox(textTag[4][2], 'Mult', 'Mult', '') and getWheel ~= 0 then		
			Multiplier = Multiplier + getWheel;
			if Multiplier > 10 then
				Multiplier = 1;
			elseif Multiplier < 1 then
				Multiplier = 10;
			end
			
			setTextString('Mult', Multiplier..'x')
			setProperty('Mult.scale.x', getProperty('Mult.scale.x') + 0.1)
			doTweenX('MultBouncyX', 'Mult.scale', 1, 0.25, 'elasticOut')
			setProperty('Mult.scale.y', getProperty('Mult.scale.y') + 0.1)
			doTweenY('MultBouncyY', 'Mult.scale', 1, 0.25, 'elasticOut')
		end	
		
		-- BG Opacity -- 
		if mouseInBox(textTag[1][2], 'Opacity', 'Opacity', '') and getWheel ~= 0 then			
			BGOpacity = BGOpacity + getWheel * Multiplier;
			if BGOpacity > 100 then
				BGOpacity = 100;
			elseif BGOpacity < 0 then
				BGOpacity = 0;
			end
			
			setTextString('Opacity', BGOpacity..'%')
			setProperty('Opacity.scale.x', getProperty('Opacity.scale.x') + 0.15)
			doTweenX('OpacityBouncyX', 'Opacity.scale', 1, 0.25, 'elasticOut')
			setProperty('Opacity.scale.y', getProperty('Opacity.scale.y') + 0.15)
			doTweenY('OpacityBouncyY', 'Opacity.scale', 1, 0.25, 'elasticOut')
		end
	
		-- Bobi --
		if mouseInBox('Bobi', '', 'Bobi', '', 3, 2.75) and not uPressedMe and mouseClicked() and bobiExist then			
			cancelTimer('CooldownDone')
			uPressedMe = true;
			animCooldown = true;
			bobiAnim('Wassap', true, 'scaleXY')
		end
	end
end

function onUpdatePost(elapsed) --For backends handling
	if keyboardJustPressed('ENTER') and not allowCountdown then
		allowCountdown = true;
		startCountdown();
	end
---------------------------------------------------------------------------------------------------------------------------------------------------------
	-- BGs --
	if BGtype >=  1 then
		for i, obj in ipairs(BGGroup[BGtype]) do
			-- [2] Behavior
			if BGtype == 2 then
				if getProperty(obj[1]..'.alpha') > 0 then
					setProperty(obj[1]..'.angle', getProperty(obj[1]..'.angle') + obj[3] * bpm/100 * elapsed)
					if getProperty(obj[1]..'.angle') == 360 or getProperty(obj[1]..'.angle') == -360 then
						setProperty(obj[1]..'.angle', 0)
					end
				end
			end
			-------------------------------------------------------------------------------------------------------------------------------
			-- [3] Square Behavior Handler
			if BGtype == 3 then
				setProperty(obj[1]..'.y', getProperty(obj[1]..'.y') - obj[3] * bpm/50 * elapsed)
				if getProperty(obj[1]..'.y') < -getProperty(obj[1]..'.height') and getProperty(obj[1]..'.alpha') > 0 then
					cancelTween(obj[1]..'Alpha')
					setProperty(obj[1]..'.alpha', 0)
					obj[4] = false;
				end
									
				if obj[4] and getProperty(obj[1]..'.alpha') > 0 then
					setProperty(obj[1]..'.alpha', getProperty(obj[1]..'.alpha') - elapsed * obj[3]/bpm)
					obj[2] = getProperty(obj[1]..'.alpha')
				end
				
				if getProperty(obj[1]..'.alpha') == 0 and disScreen then
					obj[4] = false;
				end
			end
		end
	end
	
	-- Particle System --
	if pSystem then
		if disScreen then
			pTick = pTick + elapsed;
		else
			pTick = pTick + elapsed/5;
		end
		if pTick >= pRate then
			pTick = 0;
						
			makeLuaSprite('sParticle'..pCount, '', getRandomInt(15, screenWidth-15), screenHeight)
			makeSize = getRandomInt(10, 50);
			makeGraphic('sParticle'..pCount, makeSize, makeSize, 'FFFFFF')
			setObjectCamera('sParticle'..pCount, 'camOther')
			if not disScreen then
				setProperty('sParticle'..pCount..'.alpha', 0)
			else
				setProperty('sParticle'..pCount..'.alpha', getRandomFloat(0.15, 1))
			end
			addLuaSprite('sParticle'..pCount, getRandomBool(50))
			
			pGroup[pCount][1] = 'sParticle'..pCount;
			pGroup[pCount][2] = getProperty('sParticle'..pCount..'.alpha');
			
			tweenTime = getRandomFloat(100, 400)/bpm;
			doTweenY('sParticleY'..pCount, 'sParticle'..pCount, getProperty('sParticle'..pCount..'.y') - getRandomInt(screenHeight/4, screenHeight/1.1), tweenTime)
			doTweenX('sParticleX'..pCount, 'sParticle'..pCount, getProperty('sParticle'..pCount..'.x') + getRandomInt(-50, 50), tweenTime)
			doTweenAlpha('sParticle'..pCount..'Alpha', 'sParticle'..pCount, 0, tweenTime)
			
			pCount = pCount + 1;
			if pCount > pMax then
				pCount = 1;
			end
		end
	end
---------------------------------------------------------------------------------------------------------------------------------------------------------
	if disScreen then
		tick = tick + elapsed;
		if tick >= 1 then --Every 1 sec
			tick = 0;
			--funni little goober
			if not animCooldown and not uPressedMe and bobiExist then
				if getRandomBool(75) then -- Reading
					bobiAnim('Reading', true);
				elseif getRandomBool(40) then -- Look Around
					bobiAnim('Looky', true, 'dirY');
				elseif getRandomBool(5) then -- Auto Wave
					bobiAnim('Wassap', true, 'scale');
				end
			end				
		end
		
		-- BG[3] Square Generator Handler
		if BGtype == 3 then
			sTick = sTick + elapsed;
			if sTick >= sRate then
				sTick = 0;
				
				getSquare = BGGroup[BGtype][sCount][1];
				setProperty(getSquare..'.x', getRandomInt(0, screenWidth - getProperty(getSquare..'.width')))
				setProperty(getSquare..'.y', getRandomInt(screenHeight/3, screenHeight + getProperty(getSquare..'.height')))
				fadeTime = 150/bpm + getRandomFloat(-25, 50)/bpm;
				BGGroup[BGtype][sCount][2] = getRandomFloat(0.15, 0.65);
				doTweenAlpha(getSquare..'Alpha', getSquare, BGGroup[BGtype][sCount][2], fadeTime, 'quadInOut')
				runTimer(getSquare..'Fadable', fadeTime + getRandomFloat(50, 200)/bpm)
				
				sCount = sCount + 1;
				if sCount > sMax then
					sCount = 1;
				end
			end
		end
	
		-- Constant Overlay Matching
		if not transitioning and getProperty('BlackBGOverlay.alpha') ~= BGOpacity/100 then
			doTweenAlpha('OverlayCatchingUp', 'BlackBGOverlay', BGOpacity/100, 0.1)
		end
		
		-- Timer --
		if liveTime then
			setTime();
		end
		
		-- SelectorBox
		if getProperty('Selector.alpha') == 0 then
			doTweenAlpha('SelectorFade', 'Selector', 1, 100/bpm, 'quadInOut')
		elseif getProperty('Selector.alpha') == 1 then
			doTweenAlpha('SelectorFade', 'Selector', 0, 100/bpm, 'quadInOut')
		end
	end
---------------------------------------------------------------------------------------------------------------------------------------------------------
	if getProperty('Bobi.animation.curAnim.finished') and bobiExist then
		if getProperty('Bobi.animation.curAnim.name') == 'Reading' then
			bobiAnim('Idle');
			if animCooldown then runTimer('CooldownDone', getRandomFloat(0.5, 3)) end
		elseif getProperty('Bobi.animation.curAnim.name') == 'Looky' or getProperty('Bobi.animation.curAnim.name') == 'Wassap' then
			bobiAnim('Idle', false, '-dirY');
			if animCooldown then runTimer('CooldownDone', getRandomFloat(0.5, 3)) end
		end
		
		if getProperty('Bobi.animation.curAnim.name') == 'Hi' then
			bobiAnim('SeHi');
		elseif getProperty('Bobi.animation.curAnim.name') == 'SeHi' then
			bobiAnim('Idle');
			animCooldown = false;
			uPressedMe = false;
		end
		
		if getProperty('Bobi.animation.curAnim.name') == 'PreBye' then
			bobiAnim('Bye');
		elseif getProperty('Bobi.animation.curAnim.name') == 'Bye' then
			setProperty('Bobi.alpha', 0)
		end
	end
	for i=1, #bobiOffset do
		if getProperty('Bobi.animation.curAnim.name') == bobiOffset[i][1] and bobiExist then
			setProperty('Bobi.offset.x', bobiOffset[i][2])
			setProperty('Bobi.offset.y', bobiOffset[i][3])
		end
	end
	
	-- Meanie!
	if luaTextExists('CRUELTY') then
		setProperty('CRUELTY.x', getRandomInt(-2, 2))
		setProperty('CRUELTY.y', screenHeight/1.3 + getRandomInt(-2, 2))
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	for i=1, #BGGroup[3] do
		if tag == BGGroup[3][i][1]..'Fadable' then
			BGGroup[3][i][4] = true;
		end
	end

	if tag == 'CooldownDone' then
		animCooldown = false;
		uPressedMe = false;
	end
	
	if tag == 'Summon' then
		summonBobi();
	end
	if tag == 'YOUREMEAN' then
		suchAMeanie();
	end
end

function onTweenCompleted(tag)
	if tag == 'SwitchState' then
		transitioning = false;
	end
	
	for i=1, pMax do
		if tag == 'sParticleY'..i then
			cancelTween('sParticleX'..i)
			cancelTween('sParticle'..i..'Alpha')
			
			removeLuaText('sParticle'..i)
		end
	end
end

function onEndSong()

end

function onDestroy()
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
function getDirection(value)
	justMaybe = getRandomInt(1, 5);
	if justMaybe == 1 then
		value = value * -1;
	elseif justMaybe == 5 then
		value = 0;
	end
	
	return value;
end

function getAngleDirection(value)
	if getRandomBool(50) then
		value = value * -1;
	end
	
	return value;
end

function gAdd(object, group)
	table.insert(group, object)
end

local charCount = 0;
local pivotCount = 0;
function makeAlphabet(daString, characterType, scale, x, y, verticalAlignment, horizontalAlignment, pivot)
	if pivot then
		makeLuaSprite('PivotVertical'..pivotCount, '', x-5*scale, y-10*scale)
		makeGraphic('PivotVertical'..pivotCount, 2.5*scale, 12.5*scale, 'FFFFFF')
		setObjectCamera('PivotVertical'..pivotCount, 'camOther')
		addLuaSprite('PivotVertical'..pivotCount)
		
		makeLuaSprite('PivotHorizontal'..pivotCount, '', x-10*scale, y-5*scale)
		makeGraphic('PivotHorizontal'..pivotCount, 12.5*scale, 2.5*scale, 'FFFFFF')
		setObjectCamera('PivotHorizontal'..pivotCount, 'camOther')
		addLuaSprite('PivotHorizontal'..pivotCount)
		
		pivotCount = pivotCount + 1;
	end
	
	xGap = x;
	tempGrp = {};
	gAdd({daString}, textTag)
	characterType = string.lower(characterType)
	for i=1, #daString do
		c = daString:sub(i, i)
		
		makeAnimatedLuaSprite('Letter'..charCount, 'alphabet', xGap, y)
		ascii = string.byte(c);
		c = string.lower(c);
		if characterType == 'normal' then
			if ascii >= 97 and ascii <= 122 then
				addAnimationByPrefix('Letter'..charCount, '', c..' lowercase ', 24, true)
			elseif ascii >= 65 and ascii <= 90 then
				addAnimationByPrefix('Letter'..charCount, '', c..' uppercase ', 24, true)
			else
				addAnimationByPrefix('Letter'..charCount, '', c..' '..characterType, 24, true)
			end
		else
			addAnimationByPrefix('Letter'..charCount, '', c..' '..characterType, 24, true)
		end
		scaleObject('Letter'..charCount, scale, scale)
		setObjectCamera('Letter'..charCount, 'camOther')
		if c == ' ' then
			setProperty('Letter'..charCount..'.visible', false)
		end
		addLuaSprite('Letter'..charCount, true)
		gAdd('Letter'..charCount, camGrp)
		gAdd('Letter'..charCount, textTag[#textTag])
		gAdd('Letter'..charCount, tempGrp)
		
		if verticalAlignment == 'center' or verticalAlignment == 'c' then
			setProperty('Letter'..charCount..'.y', y - getProperty('Letter'..charCount..'.height')/1.75)
		elseif verticalAlignment == 'bottom' or verticalAlignment == 'b' then
			setProperty('Letter'..charCount..'.y', y - getProperty('Letter'..charCount..'.height') * 1.15)
		end
		
		xGap = xGap + getProperty('Letter'..charCount..'.width')
		charCount = charCount + 1;
	end
	
	if horizontalAlignment == 'center' or horizontalAlignment == 'c' then
		getMid = #tempGrp / 2;
		if getMid == math.ceil(#tempGrp/2) then
			setProperty(tempGrp[getMid]..'.x', x - getProperty(tempGrp[getMid]..'.width')*1.1)
			
			for i=getMid-1, 1, -1 do
				setProperty(tempGrp[i]..'.x', getProperty(tempGrp[i+1]..'.x') - getProperty(tempGrp[i]..'.width'))
			end
			for i=getMid+1, #tempGrp do
				setProperty(tempGrp[i]..'.x', getProperty(tempGrp[i-1]..'.x') + getProperty(tempGrp[i-1]..'.width'))
			end
		else
			getMid = getMid + 0.5;
		
			setProperty(tempGrp[getMid]..'.x', x - getProperty(tempGrp[getMid]..'.width')/1.65)
			
			for i=getMid-1, 1, -1 do
				setProperty(tempGrp[i]..'.x', getProperty(tempGrp[i+1]..'.x') - getProperty(tempGrp[i]..'.width'))
			end
			for i=getMid+1, #tempGrp do
				setProperty(tempGrp[i]..'.x', getProperty(tempGrp[i-1]..'.x') + getProperty(tempGrp[i-1]..'.width'))
			end
		end
	elseif horizontalAlignment == 'right' or horizontalAlignment == 'r' then
		setProperty(tempGrp[#tempGrp]..'.x', x - getProperty(tempGrp[#tempGrp]..'.width')*1.25)
		for i=#tempGrp-1, 1, -1 do
			setProperty(tempGrp[i]..'.x', getProperty(tempGrp[i+1]..'.x') - getProperty(tempGrp[i]..'.width'))
		end
	end
	
	-- debugPrint("["..daString.."] created!")
end

function makeText(tag, daString, scale, length, x, y, alignment)
	if alignment == nil or alignment == '' then
		alignment = 'left'
	end
	
	if length == 'auto' or length == '#' then
		makeLuaText(tag, daString, 5, x, y)
	else
		makeLuaText(tag, daString, length, x, y)
	end
	setObjectCamera(tag, 'camOther')
	setTextAlignment(tag, alignment)
	setTextSize(tag, 80*scale)
	if length == 'auto' or length == '#' then
		iterateHeight(tag, scale)
	end
	gAdd(tag, camGrp)
	addLuaText(tag, true)
end

function iterateHeight(tag, scale)
	makeLuaText('getHeight', 'ImDaeBob was here!', 500, 0, 0)
	setObjectCamera('getHeight', 'camOther')
	setTextSize('getHeight', 80*scale)
	addLuaText('getHeight')
	
	textHeight = getProperty('getHeight.height')
	-- debugPrint(textHeight)
	removeLuaText('getHeight', true)

	while getProperty(tag..'.height') > textHeight do
		setTextWidth(tag, getTextWidth(tag) + 10)
	end
end

function summonBobi()
	if bobiExist then
		setProperty('Bobi.alpha', 1)
		bobiAnim('Hi')
	end
end

function bobiAnim(anim, isSpecial, bounce)
	if bobiExist then
		if isSpecial == nil or isSpecial == '' then
			isSpecial = false;
		end
		if isSpecial then
			animCooldown = true;
		end
	
		objectPlayAnimation('Bobi', anim, true)
		
		if bounce ~= '' and bounce ~= nil then
			if bounce == 'dirY' then
				setProperty('Bobi.y', getProperty('Bobi.y') - 3)
				doTweenY('BobiY', 'Bobi', getProperty('Bobi.y') + 3, 0.5, 'backOut')
			elseif bounce == '-dirY' then
				setProperty('Bobi.y', getProperty('Bobi.y') + 2)
				doTweenY('BobiY', 'Bobi', getProperty('Bobi.y') - 2, 0.5, 'backOut')	
			elseif bounce == 'scale' then
				if getRandomBool(50) then
					setProperty('Bobi.scale.x', getProperty('Bobi.scale.x') - 0.015)
					doTweenX('BobiBouncyX', 'Bobi.scale', getProperty('Bobi.scale.x')+0.015, 0.5, 'elasticOut')
				else
					setProperty('Bobi.scale.y', getProperty('Bobi.scale.y') - 0.015)
					doTweenY('BobiBouncyY', 'Bobi.scale', getProperty('Bobi.scale.y')+0.015, 0.5, 'elasticOut')
				end
			elseif bounce == 'scaleX' then
				setProperty('Bobi.scale.x', getProperty('Bobi.scale.x') - 0.02)
				doTweenX('BobiBouncyX', 'Bobi.scale', getProperty('Bobi.scale.x')+0.02, 0.5, 'elasticOut')
			elseif bounce == 'scaleY' then
				setProperty('Bobi.scale.y', getProperty('Bobi.scale.y') - 0.02)
				doTweenY('BobiBouncyY', 'Bobi.scale', getProperty('Bobi.scale.y')+0.02, 0.5, 'elasticOut')
			else 
				setProperty('Bobi.scale.x', getProperty('Bobi.scale.x') - 0.02)
				doTweenX('BobiBouncyX', 'Bobi.scale', getProperty('Bobi.scale.x')+0.02, 0.5, 'elasticOut')
				setProperty('Bobi.scale.y', getProperty('Bobi.scale.y') - 0.02)
				doTweenY('BobiBouncyY', 'Bobi.scale', getProperty('Bobi.scale.y')+0.02, 0.5, 'elasticOut')
			end
		end
	end
end

function suchAMeanie() -- YOU ARE MEAN AND PROBABLY THE WORST PERSON EVER!!
	excLetter = "";
	for i=1, getRandomInt(5, 10) do
		meanieFile = "";
		excLetter = excLetter..'!';

		if package.config:sub(1,1) == '\\' then -- Windows
			meanieFile = os.getenv("USERPROFILE").."\\Desktop\\YOU UNGRATEFUL HUMAN-BEING"..excLetter..".txt";
		else -- Unix-based (Linux/macOS)
			meanieFile = os.getenv("HOME").."/Desktop/YOU UNGRATEFUL HUMAN-BEING"..excLetter..".txt";
		end
		
		urMean = io.open(meanieFile, "w")
		urMean:write(
			"If you don't and can't bother to have a little me in your screen then you just a disrespectful and ungrateful human being, what's wrong with having a little me in it?\n\n"..
			"What? You don't like fun or something? What's there to hate about me??\n\n"..
			"I literally spent days on this for you to use but you can't bother to spend 1 second to also cut and paste me in with the script!??\n\n"..
			"I did my best to not use any extra assets for this feature but just having me as a signature of my work is that much of a bothersome???\n\n"..
			"YOU'RE MEAN!!\n"..
			">:(\n"..
			"I wish you everything bad may happen to you!!")
		if getRandomBool(25) then
			urMean:write("\n\nF##K YOU!")
		end
		urMean:close()
		
		-- Open the file using the default text editor
		if package.config:sub(1,1) == '\\' then -- Windows
			os.execute('start "" "'..meanieFile..'"')
		else -- Unix-based (Linux/macOS)
			os.execute('open "'..meanieFile..'"')
		end
	end
end

function unhideFile(file)
    if package.config:sub(1, 1) == '\\' then -- Check if running on Windows
		command = 'attrib -h "' .. file .. '"'
        os.execute(command)
    else -- Unix-based system (Linux/macOS): remove the leading '.' if present
        if file:match("/%.([^/]+)$") then
            visibleFile = file:gsub("/%.", "/")
            os.execute('mv "'..file..'" "'..visibleFile..'"')
        end
    end
end


function hideFile(file)
    if package.config:sub(1,1) == '\\' then -- Windows system        
        local command = 'attrib "'..file..'"'
        local handle = io.popen(command)
        local result = handle:read("*a")
        handle:close()
        
        -- Check if folder already hidden yet
        if not result:find("H") then
            os.execute('attrib +h "'..file..'"')
        end
    else -- Unix-based system (Linux/macOS)
        -- Check if folder already hidden yet
        if not file:match("/%.([^/]+)$") then
            -- Hide it
            local hiddenFile = file:gsub("([^/]+)$", ".%1")
            os.execute('mv "'..file..'" "'..hiddenFile..'"')
        end
    end
end

function matchBox(object)
	if getProperty('Selector.x') ~= getProperty(object..'.x') or getProperty('Selector.y') ~= getProperty(object..'.y') then
		makeLuaSprite('Selector', '', getProperty(object..'.x'), getProperty(object..'.y'))
		makeGraphic('Selector', getProperty(object..'.width'), getProperty(object..'.height'), 'FFFFFF')
		setObjectCamera('Selector', 'camOther')
		setObjectOrder('Selector', getObjectOrder(object))
		setProperty('Selector.alpha', 0.8)
		addLuaSprite('Selector', true)
		
		doTweenAlpha('SelectorFade', 'Selector', 0, 100/bpm, 'quadInOut')
	end
end

--Obj1 is Starting Point | Obj2 is Ending Point + Obj2.width/height | Div is for rescalling the sprite's hitbox
function mouseInBox(objX1, objX2, objY1, objY2, div1, div2)
	if objX2 == nil or objX2 == '' then
		objX2 = objX1;
	elseif objX1 == nil or objX1 == '' then
		objX1 = objX2;
	end
	if objY2 == nil or objY2 == '' then
		objY2 = objY1;
	elseif objY1 == nil or objY1 == '' then
		objY1 = objY2;
	end
	if div1 == nil or div1 == '' or div1 == 0 then
		div1 = 1;
	end
	if div2 == nil or div2 == '' or div2 == 0 then
		div2 = 1;
	end

	if mX() >= getProperty(objX1..'.x') and mX() <= getProperty(objX2..'.x') + getProperty(objX2..'.width')/div1
	and mY() >= getProperty(objY1..'.y') and mY() <= getProperty(objY2..'.y') + getProperty(objY2..'.height')/div2 then
		return true;
	end
	return false;
end

function mX()
	return getMouseX('camOther');
end

function mY()
	return getMouseY('camOther');
end

function setTime(insert)
	if insert == nil or insert == '' then
		getTime = getSongPosition()/1000;
	else
		getTime = insert;
	end
	if getTime < 0 then
		getTime = 0;
	end
	
	makeMin = math.floor(getTime/60);
	if makeMin <= 9 then
		makeMin = '0'..makeMin;
	end
	makeSec = math.floor(getTime%60);
	if makeSec <= 9 then
		makeSec = '0'..makeSec;
	end		

	setTextString('Time', makeMin..':'..makeSec)
	setTextString('Seconds', (math.floor(getTime * 100)/100))
	setTextString('Steps', math.floor((getTime*bpm*4)/60))
end