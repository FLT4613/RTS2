package;

import flash.Lib;

import gameComponents.*;
import flixel.math.FlxPoint;

class Message{
  private static var serial:Int = 0;
  public var id(default,null):Int;
  public var sender(default,null):Dynamic;
  public var body(default,null):MessageBody;
  public var type(default,null):MessageType;
  public var timing(default,null):Timing;
  public var timestamp(default,null):Float;

  public function new(sender:Dynamic,body:MessageBody,type:MessageType,timing:Timing){
    id = serial;
    serial++;
    this.sender = sender;
    this.body = body;
    this.type = type;
    this.timing = timing;
    this.timestamp =  flash.Lib.getTimer();
  }
}

enum MessageType{
  BROADCAST;
  UNICAST(destination:Dynamic);
  MULTICAST(destinations:Array<Dynamic>);
}

enum Timing{
  INSTANT;
  NEXTFRAME;
  AFTER(frame:Int);
}

enum MessageBody{
  OK;
  IMHERE(point:FlxPoint);
  CLICK(point:FlxPoint);
  CLICKED;
  PICK;
  PICKED;
  UNPICKED;
  GENERATE(point:FlxPoint,properties:Map<String,String>);
  DAMAGE(damage:Int);
  MOVE(point:FlxPoint);
  FOUND(obj:GameObject);
  LOST(obj:GameObject);
  ERROR(code:MessageErrorCode);
}

enum MessageErrorCode{
  NOT_FOUND;
  FORBIDDEN;
}
