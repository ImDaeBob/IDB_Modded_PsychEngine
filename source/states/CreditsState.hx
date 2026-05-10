package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	var teamNotEmpty:Bool = false;
	private var titleScale:Float = 0.75;
	private var teamList:Array<String>;
	private var daTeam:Alphabet;
	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	private var creditTextGroup:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var titleBox:FlxSprite;
	var descBox:AttachedSprite;

	var offsetThing:Float = -50;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits", null);
		#end

		persistentUpdate = true;

		creditTextGroup = new FlxTypedGroup<Alphabet>();
		add(creditTextGroup);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		teamList = Mods.mergeAllTextsNamed('images/credits/creditGroups.txt');
		if (teamList != null) {
			teamNotEmpty = true;
			for (i in 0...teamList.length)
				teamList[i] = teamList[i].toLowerCase();
			changeTeam();
		}

		bg.color = CoolUtil.colorFromString('FFFFFF');
		intendedColor = bg.color;

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if(!quitting)
		{
			if (teamNotEmpty) 
			{
				if (teamList.length > 1)
				{
					var leftP = controls.UI_LEFT_P;
					var rightP = controls.UI_RIGHT_P;
	
					if (leftP)
						changeTeam(-1);
					if (rightP)
						changeTeam(1);
				}
		
				if(creditsStuff.length > 1)
				{
					var shiftMult:Int = 1;
					if(FlxG.keys.pressed.SHIFT) shiftMult = 3;
	
					var upP = controls.UI_UP_P;
					var downP = controls.UI_DOWN_P;
	
					if (upP)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (downP)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}
	
					if (controls.UI_DOWN || controls.UI_UP)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
	
						if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
							changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][4] != null && creditsStuff[curSelected][4].length > 4))
				CoolUtil.browserLoad(creditsStuff[curSelected][4]);

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in creditTextGroup.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}

		super.update(elapsed);
	}

	var curTeam = 0;
	var leftTween:FlxTween = null;
	var rightTween:FlxTween = null;
	function changeTeam(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curTeam += change;
		if (curTeam < 0)
			curTeam = teamList.length - 1;
		if (curTeam >= teamList.length)
			curTeam = 0;

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Get data from that team!

		curSelected = -1;

		while (creditsStuff.length > 0)
   			creditsStuff = [];
		while (creditTextGroup.length > 0)
		{
			creditTextGroup.forEachAlive(function(text:Alphabet) text.destroy());
			creditTextGroup.clear();
		}
		
   		for (icon in iconArray) {
   		    icon.destroy();
   		}
   		iconArray = [];

		if (descBox != null)
		{
			descBox.sprTracker = null;
			descBox.destroy();
		}

		if (descText != null)
			descText.destroy();

		var getContent:Array<String> = [];
		getContent = Mods.mergeAllTextsNamed('images/credits/' + teamList[curTeam] + '/credits.txt', null, true);
		if (getContent != null)
		{
			for(i in getContent)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("||");
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);

			for (i in 0...creditsStuff.length)
			{
				var isSelectable:Bool = !unselectableCheck(i);
				var offsetY = 0;
				if (!isSelectable)
					offsetY = 50;
				var creditText:Alphabet = new Alphabet(FlxG.width / 2, 300 + offsetY, creditsStuff[i][0], !isSelectable);
				// trace(creditsStuff[i][0] + ' -- ' + isSelectable);
				creditText.isMenuItem = true;
				creditText.targetY = i;
				creditText.changeX = false;
				creditText.snapToPosition();
				add(creditText);
				creditTextGroup.add(creditText);
	
				if(isSelectable) {
					var str:String = 'credits/null';
					if(creditsStuff[i][1] != null && creditsStuff[i][1].length > 0)
					{
						var fileName = 'credits/${teamList[curTeam]}/${creditsStuff[i][1]}';
						if (Paths.fileExists('images/$fileName.png', IMAGE)) 
							str = fileName;
						else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) 
							str = fileName + '-pixel';

						var icon:AttachedSprite = new AttachedSprite(str);
						if(str.endsWith('-pixel')) 
							icon.antialiasing = false;
						icon.xAdd = creditText.width + 10;
						icon.sprTracker = creditText;
			
						iconArray.push(icon);
						add(icon);
					}
	
					if(curSelected == -1) curSelected = i;
				}
				else creditText.alignment = CENTERED;
			}
			
			descBox = new AttachedSprite();
			descBox.makeGraphic(1, 1, FlxColor.BLACK);
			descBox.xAdd = -10;
			descBox.yAdd = -10;
			descBox.alphaMult = 0.6;
			descBox.alpha = 0.6;
			add(descBox);
	
			descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
			descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
			descText.scrollFactor.set();
			descBox.sprTracker = descText;
			add(descText);

			changeSelection();
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Create the team header!

		createTeamTitle(teamList[curTeam]); //Ensure this will always be ahead of the credits below

		if (change == 0) {
			selectorLeft.x = daTeam.x - selectorLeft.width*1.3;
			selectorRight.x = daTeam.x + daTeam.width + selectorRight.width/3;
		}	
		else if (change <= -1) {
			selectorRight.x = daTeam.x + daTeam.width + selectorRight.width/3;

			selectorLeft.x = daTeam.x - selectorLeft.width*2.6;
			if (leftTween != null) 
				leftTween.cancel();
			leftTween = FlxTween.tween(selectorLeft, {x : daTeam.x - selectorLeft.width*1.3}, 0.25, {ease: FlxEase.sineOut});
		}
		else if (change >= 1) {
			selectorLeft.x = daTeam.x - selectorLeft.width*1.3;

			selectorRight.x = daTeam.x + daTeam.width + selectorRight.width*1.3;
			if (rightTween != null) 
				rightTween.cancel();
			rightTween = FlxTween.tween(selectorRight, {x : daTeam.x + daTeam.width + selectorRight.width/3}, 0.25, {ease: FlxEase.sineOut});
		}
	}

	function createTeamTitle(title:String = "NULL")
		{
			if (daTeam != null)
				daTeam.destroy();
			if (selectorLeft != null)
				selectorLeft.destroy();
			if (selectorRight != null)
				selectorRight.destroy();
			if (titleBox != null)
				titleBox.destroy();
	
			titleBox = new FlxSprite().makeGraphic(FlxG.width, 90, 0xFF000000);
			titleBox.alpha = 0.75;
			add(titleBox);
	
			daTeam = new Alphabet(0, 20, title, true);
			daTeam.scaleX = titleScale;
			daTeam.scaleY = titleScale;
			daTeam.screenCenter(X);
			add(daTeam);
	
			selectorLeft = new Alphabet(0, 20, '<', true);
			selectorLeft.scaleX = titleScale;
			selectorLeft.scaleY = titleScale;
			add(selectorLeft);
	
			selectorRight = new Alphabet(0, 20, '>', true);
			selectorRight.scaleX = titleScale;
			selectorRight.scaleY = titleScale;
			add(selectorRight);
		}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][2]);
		if(newColor != intendedColor) {
			if(colorTween != null)
				colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bit:Int = 0;
		for (item in creditTextGroup.members)
		{
			item.targetY = bit - curSelected;
			bit++;

			if(!unselectableCheck(bit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][3];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) 
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 2;
	}
}
