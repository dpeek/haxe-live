@:build(Macro.build())
class Main
{
	static var live:Live;
	static function main() new Main();

	var sprite:flash.display.Sprite;

	function new()
	{
		live = new Live();
		
		flash.Lib.current.stage.frameRate = 60;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		sprite = new flash.display.Sprite();
		flash.Lib.current.addChild(sprite);

		sprite.addEventListener(flash.events.Event.ENTER_FRAME, update);
	}

	function draw(color:Int)
	{
		sprite.graphics.clear();
		sprite.graphics.beginFill(color);
		sprite.graphics.drawRect(0,0,100, 100);
	}

	@live function update(_)
	{
		callMethod(this, this.draw, [0xFF]);
		this.sprite.x = this.sprite.x - 1;
		if (this.sprite.x < 0) this.sprite.x = 400;
	}
}
