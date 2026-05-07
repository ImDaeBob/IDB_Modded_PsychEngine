package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isPlayer:Bool = false;
	private var char:String = '';
	private var isAnimated:Bool = false;
	private var hasLosingAnim:Bool = true;
	private var hasWinningAnim:Bool = false;

	//This is the Default Framerate for Freeplay, get BPM from the freakyMenu and divide it by 6 and you get get the perfect FPS :D ~ ImDaeBob
	public static var iconFPS:Int = 17;

	public function new(char:String = 'null', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/null'; //Prevents crash from missing icon
			
			isAnimated = Paths.fileExists('images/' + name + '.xml', IMAGE); //Get if it is an animated icon
			if (!isAnimated)
			{
				var graphic = Paths.image(name, allowGPU);
				loadGraphic(graphic); //Load the file first to get the file size!

				var widthDiv:Int = 2;
				hasWinningAnim = (graphic.width == 3 * graphic.height); //Since each icon is 150 pixels for both width and height anyways
				if(hasWinningAnim) 
					widthDiv = 3;

				hasLosingAnim = (graphic.width == 2 * graphic.height) || hasWinningAnim;
				if(!hasLosingAnim) 
					widthDiv = 1;

				loadGraphic(graphic, true, Math.floor(graphic.width / widthDiv), Math.floor(graphic.height)); //Now actually load for real!
				iconOffsets[0] = (width - 150) / widthDiv;
				iconOffsets[1] = (height - 150) / widthDiv;
				updateHitbox();
	
				animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
				animation.play(char);
			}
			else
			{
				frames = Paths.getSparrowAtlas(name);

				animation.addByPrefix('default', 'normal', iconFPS, true, isPlayer);
				animation.addByPrefix('losing', 'losing', iconFPS, true, isPlayer);
				animation.addByPrefix('winning', 'winning', iconFPS, true, isPlayer);
				animation.play('default');
			}
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	public var autoAdjustOffset:Bool = true;
	override function updateHitbox()
	{
		super.updateHitbox();
		if(autoAdjustOffset)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function getCharacter():String {
		return char;
	}

		public function changeAnim(isLosing:Bool, ?isWinning:Bool = false) {
		if(!isAnimated) 
		{
			if(!isLosing && !isWinning)
				animation.curAnim.curFrame = 0;
			else if(isLosing && hasLosingAnim)
				animation.curAnim.curFrame = 1;
			else if(isWinning && hasWinningAnim)
				animation.curAnim.curFrame = 2;
		} 
		else 
		{
			if(!isLosing && !isWinning)
				animation.play('normal');
			else if(isLosing)
				animation.play('losing');
			else if(isWinning)
				animation.play('winning');
		}
	}
}
