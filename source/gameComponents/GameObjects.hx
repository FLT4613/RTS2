package gameComponents;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxGroup;
import Messenger;
import Receiver;
import flixel.FlxG;
using Message;
using Lambda;

class GameObjects extends FlxTypedGroup<GameObject> implements Receiver
{
  public static var instance(default, null): GameObjects = new GameObjects();
  private var messenger: Messenger = Messenger.instance;
  private var messages: Array<Message> = new Array<Message>();

  public function new(): Void {
    super();
  }

  override public function update(elapsed) {
    super.update(elapsed);
    var friend = new Map();
    var friendList = new FlxGroup();
    var enemy = new Map();
    var enemyList = new FlxGroup();
    var friendSights = new FlxGroup();
    var enemySights = new FlxGroup();
    forEachAlive(function(x) {
      switch(x.force) {
        case "friend":
          friend.set(x.rectRange, x);
          friendList.add(x);

          if(x.rectRange != null) {
            friendSights.add(x.rectRange);
          }

        case "enemy":
          enemy.set(x.rectRange, x);
          enemyList.add(x);

          if(x.rectRange != null) {
            enemySights.add(x.rectRange);
          }
      }
    });
    FlxG.overlap(friendSights, enemyList, function(friendSight, enemy: GameObject) {
      var receiver: GameObject = friend[friendSight];
      var mes = new Message(this, FOUND(enemy), UNICAST(receiver), INSTANT);
      messenger.dispatch(mes);
    });
    FlxG.overlap(enemySights, friendList, function(enemySight, friend: GameObject) {
      var receiver: GameObject = enemy[enemySight];
      var mes = new Message(this, FOUND(friend), UNICAST(receiver), INSTANT);
      messenger.dispatch(mes);
    });
  }

  public function receive(message: Message) {
    switch(message.body) {
      case GENERATE(generatePoint, properties):
        var dead = getFirstAvailable();

        if(dead != null) {
          dead.reset(generatePoint.x, generatePoint.y);
        } else {
          var obj = new GameObject(generatePoint.x, generatePoint.y, properties["force"]);
          obj.reset(generatePoint.x, generatePoint.y);
          this.add(obj);
          messenger.appendRoute(obj);
        }

      case CLICK(clickPoint):
        var min = 16.0;
        var near = members.filter(
        function(x) {
          return x.getMidpoint().distanceTo(clickPoint) <= min && x.exists;
        });

        if(!near.empty()) {
          near.sort(function(x, y) {
            return Std.int(x.getMidpoint().distanceTo(clickPoint) - x.getMidpoint().distanceTo(clickPoint));
          });
          var nearest = near.pop();

          if(nearest != null) {
            var mes = new Message(this, PICK, UNICAST(nearest), INSTANT);
            messenger.dispatch(mes);
          }
        } else {
          messenger.dispatch(new Message(this, MOVE(clickPoint), MULTICAST(members), INSTANT));
        }

      default:
        null;
    }
  }
}