package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;

import Messenger;
import gameComponents.*;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

import flash.Lib;
class PlayState extends FlxState
{
  private var messenger = Messenger.instance;

  private var frame: Float = 0.0;
  private var loopCount: Int = 0;

  override public function create(): Void
  {
    super.create();
    FlxG.fixedTimestep = false;
    FlxG.mouse.useSystemCursor = true;
    var backGround = new FlxSprite(0, 0);
    backGround.makeGraphic(640, 480, FlxColor.WHITE);

    add(backGround);

    add(GameObjects.instance);

    messenger.appendRoute(GameObjects.instance);
    // messenger.appendRoute(GameObjects.instance);
    // add(field);
    // messenger.appendRoute(field);
    FlxG.debugger.visible = true;
  }

  override public function update(elapsed: Float): Void
  {
    super.update(elapsed);
    // trace('[$loopCount]---------------------');
    // loopCount++;
    if(FlxG.keys.justPressed.A) {
      var message = new Message(this, GENERATE(FlxG.mouse.getPosition(), ["force" => "friend"]),
                                BROADCAST, INSTANT);
      messenger.dispatch(message);
    }

    if(FlxG.keys.justPressed.Q) {
      for(i in 0...10) {
        var point = FlxG.mouse.getPosition().add(FlxG.random.int(-100, 100), FlxG.random.int(-100, 100));
        var message = new Message(
          this,
          GENERATE(point, ["force" => "friend"]),
          BROADCAST,
          INSTANT
        );
        messenger.dispatch(message);
      }
    }

    if(FlxG.keys.justPressed.S) {
      var message = new Message(this, GENERATE(FlxG.mouse.getPosition(), ["force" => "enemy"]), BROADCAST,
                                INSTANT);
      messenger.dispatch(message);
    }

    if(FlxG.mouse.justPressed) {
      var message = new Message(this, CLICK(FlxG.mouse.getPosition()), BROADCAST, INSTANT);
      messenger.dispatch(message);
    }

    messenger.poll();

  }
}
