package gameComponents;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxPath;
import flixel.math.FlxVelocity;
import flixel.math.FlxRandom;

import flixel.FlxG;

import Messenger;
import Receiver;
using Message;
using Lambda;
using tweenxcore.Tools;

class GameObject extends FlxSprite implements Receiver
{
  public var fsm: FlxFSM<GameObject>;
  public var chosen: Bool = false;
  private var messenger: Messenger = Messenger.instance;
  private var messages: Array<Message> = new Array<Message>();
  private var maxHealth = 20;
  public var searchRange = 100;
  public var rectRange: FlxObject = new FlxObject(0, 0);
  public var force: String;
  public var chaseTarget: GameObject;

  public function new(x: Float, y: Float, force: String): Void {
    super(x, y);
    loadGraphic(AssetPaths.character__png, true, 32, 32, true);
    animation.add("IdleLeft", [0], 10, true);
    animation.add("IdleRight", [4], 10, true);
    animation.add("MoveLeft", [0, 1, 2, 3], 10, true);
    animation.add("MoveRight", [4, 5, 6, 7], 10, true);
    animation.add("AttackLeft", [8, 9, 10, 11], 10, true);
    animation.add("AttackRight", [12, 13, 14, 15], 10, true);
    animation.add("DamageLeft", [16]);
    animation.add("DamageRight", [17]);
    animation.add("DeadLeft", [18]);
    animation.add("DeadRight", [19]);

    path = new FlxPath();
    fsm = new FlxFSM<GameObject>(this);
    rectRange.setSize(100, 100);
    rectRange.setPosition(getMidpoint().x - (rectRange.width / 2), getMidpoint().y - (rectRange.height / 2));
    facing = FlxObject.RIGHT;

    health = maxHealth;
    this.force = force;
    fsm.transitions
    .add(Standby,  DeadStart, function(owner: GameObject) {
      return owner.health <= 0;
    })
    .add(Standby, Move, function(owner: GameObject) {
      return path.nodes.length > 0;
    })
    .add(Standby, Attack, function(owner: GameObject) {
      return owner.chaseTarget != null;
    })
    .add(Move, Standby, function(owner: GameObject) {
      return path.finished;
    })
    .add(Move, Attack, function(owner: GameObject) {
      return owner.chaseTarget != null;
    })
    .add(Attack, Standby, function(owner: GameObject) {
      return owner.chaseTarget == null;
    })
    .add(Move, DeadStart, function(owner: GameObject) {
      return owner.health <= 0;
    })
    .add(Attack, Knockback, function(owner: GameObject) {
      return owner.health <= 0;
    })
    .add(Dead, Standby, function(owner: GameObject) {
      return owner.health > 0 && owner.alive && owner.exists;
    })
    .start(Standby);
  }

  override public function update(elapsed: Float): Void
  {
    rectRange.setPosition(x, y);
    fsm.update(elapsed);
    super.update(elapsed);

    if(FlxG.keys.justPressed.O) {
      fsm.state = new Knockback();
    }

    if(FlxG.keys.justPressed.P) {
      fsm.state = new DeadStart();
    }

    if(chosen) {
      setGraphicSize(40, 40);
    } else {
      setGraphicSize(32, 32);
    }
  }

  override public function revive() {
    super.revive();
    health = maxHealth;
    rectRange.setPosition(x, y);
  }

  public function receive(message: Message) {
    if(fsm.stateClass != Dead) {
      switch(message.body) {
        case PICK:
          var mes = new Message(this, PICKED, BROADCAST, INSTANT);
          trace("Im choosed =>" + this.getPosition());
          chosen = !chosen;
          messenger.dispatch(mes);

        case MOVE(point):
          if(chosen) {
            chosen = false;
            path.addPoint(point);
          }

        case FOUND(obj):
          if(chaseTarget == null) {
            chaseTarget = obj;
          }

        default:
          null;
      }
    }
  }
}

private class Standby extends FlxFSMState<GameObject> {
  private var time: Float = 0.0;
  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("立ち状態開始");

    if(owner.facing == FlxObject.RIGHT) {
      owner.animation.play("IdleRight");
    } else {
      owner.animation.play("IdleLeft");
    }
  }

  override public function update(elapsed: Float, owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    if(time > 5.0) {
      time = 0.0;

      if(FlxG.random.bool()) {
        owner.animation.play("IdleLeft");
      } else {
        owner.animation.play("IdleRight");
      }
    }
  }

  override public function exit(owner: GameObject): Void {
    trace("立ち状態終了");
  }
}

private class Move extends FlxFSMState<GameObject> {
  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("移動状態開始");
    owner.path.start(
      null,
      100.0
    );
  }

  override public function update(elapsed: Float, owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    if(owner.path.angle > 0) {
      owner.facing = FlxObject.RIGHT;
    } else {
      owner.facing = FlxObject.LEFT;
    }

    if(owner.facing == FlxObject.RIGHT) {
      owner.animation.play("MoveRight");
    } else {
      owner.animation.play("MoveLeft");
    }
  }

  override public function exit(owner: GameObject): Void {
    trace("移動状態終了");
    owner.path.cancel();
    owner.path.nodes = [];
  }
}

private class Attack extends FlxFSMState<GameObject> {
  var target: GameObject;
  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("攻撃開始");
    target = owner.chaseTarget;
  }

  override public function update(elapsed: Float, owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    if(owner.getMidpoint().angleBetween(target.getGraphicMidpoint()) > 0) {
      owner.facing = FlxObject.RIGHT;
    } else {
      owner.facing = FlxObject.LEFT;
    }

    if(target.getMidpoint().distanceTo(owner.getMidpoint()) > 10) {
      FlxVelocity.moveTowardsPoint(owner, target.getMidpoint());

      if(owner.facing == FlxObject.RIGHT) {
        owner.animation.play("MoveRight");
      } else {
        owner.animation.play("MoveLeft");
      }
    } else {
      // Attack
      owner.velocity.set(0, 0);

      if(owner.facing == FlxObject.RIGHT) {
        owner.animation.play("AttackRight");
      } else {
        owner.animation.play("AttackLeft");
      }

      target.health -= 10.0 * elapsed;
    }

    if(target.alive == false) {
      owner.chaseTarget = null;
    }
  }

  override public function exit(owner: GameObject): Void {
    trace("攻撃終了");
    owner.velocity.set(0, 0);
  }
}

private class DeadStart extends FlxFSMState<GameObject> {
  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("Start DeadStart");
    owner.alive = false;
  }
  override public function update(elapsed: Float, owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    if(fsm.age > 5.0) {
      fsm.state = new Dead();
    }

    if(owner.facing == FlxObject.RIGHT) {
      owner.animation.play("DeadRight");
    } else {
      owner.animation.play("DeadLeft");
    }
  }
}

private class Dead extends FlxFSMState<GameObject> {
  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("Start Dead");
    owner.animation.play("DeadLeft");
    owner.chaseTarget = null;
    owner.kill();
  }
  override public function exit(owner: GameObject): Void {
    trace("End Dead");
  }
}

private class Knockback extends FlxFSMState<GameObject> {
  public static var TOTAL_FRAME: Int = 40;
  //  フレーム数
  private var frameCount: Int = 0;
  // ノックバック前の座標
  private var origin: FlxPoint;
  // 乱数生成
  public static var random: FlxRandom = new FlxRandom();

  private var power: FlxPoint;

  // public function new(po) {
  //   super();
  // }

  override public function enter(owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    trace("ノックバック開始 ");
    origin = FlxPoint.weak(owner.x, owner.y);

    // if(owner.facing == FlxObject.RIGHT) {
    //   sign = -1;
    // }
    power = FlxPoint.weak(Std.random(200) * random.sign(), 100);
  }

  override public function update(elapsed: Float, owner: GameObject, fsm: FlxFSM<GameObject>): Void {
    if(owner.facing == FlxObject.RIGHT) {
      owner.animation.play("DamageRight");
    } else {
      owner.animation.play("DamageLeft");
    }

    var rate = frameCount / TOTAL_FRAME;

    if(rate <= 1) {
      owner.x = rate.linear().lerp(origin.x, origin.x + power.x);
      owner.y = rate.yoyo(Easing.quadOut).lerp(origin.y, origin.y - power.y);
    } else {
      fsm.state = new DeadStart();
    }

    frameCount++;
  }

  override public function exit(owner: GameObject): Void {
    trace("ノックバック終了");
  }
}
