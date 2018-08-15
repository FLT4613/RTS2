// package gameComponents;

// import flixel.tile.FlxTilemap;

// import Messenger;
// import Receiver;
// using Message;

// class Field extends FlxTilemap implements Receiver
// {
//   public static var instance(default,null):Field = new Field();
//   private var messenger:Messenger = Messenger.instance;
//   private var messages:Array<Message> = new Array<Message>();

//   override private function new()
//   {
// 	  super();
//   }

//   override public function update(elapsed)
//   {
//     super.update(elapsed);
//     var message = receive();
//     if(message != null){
//       trace('Field RECEIVE:${message.body}(${message.timestamp})');
//       trace('NOW:${flash.Lib.getTimer()}');
//     }
//   }

//   public function store(message:Message){
//     messages.push(message);
//     trace('Field STORE:${message.body}(${message.timestamp})');
//   }


//   private function receive():Message{
//     return messages.pop();
//   }

//   public function fetch():Message{
//     return messages.pop();
//   }
// }
