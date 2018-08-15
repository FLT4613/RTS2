package;
import Receiver;

using Lambda;

class Messenger
{
  public static var instance(default, null): Messenger = new Messenger();
  private var route: Array<Dynamic> = new Array<Dynamic>();
  private var messages = new Array<Message>();
  private var nextMessages = new Array<Message>();
  private function new() {
    return;
  }

  public function appendRoute(receiver: Dynamic): Bool {
    if(!Std.is(receiver, Receiver)) {
      trace(Type.getClassName(Type.getClass(receiver)) + " : Not Receiver");
      return false;
    }

    trace("Add " + Type.getClassName(Type.getClass(receiver)));
    route.push(receiver);
    return true;
  }

  public function dispatch(message: Message) {
    // trace('[#${message.id}]SEND:${message.body}(${message.timestamp})');
    nextMessages.push(message);
  }

  public function poll() {
    if(nextMessages.length > 0) {
      do {
        messages = nextMessages;
        nextMessages = [];
        // ゆにきゃすとに対応
        // nextframe対応(nextmessages=messages でいいんじゃない？
        // pub-sub
        messages.iter(function(message) {
          switch(message.type) {
            case BROADCAST:
              route.iter(function(receiver: Receiver) {
                if(receiver != message.sender) {
                  receiver.receive(message);
                }
              });

            case UNICAST(obj):
              if(route.has(obj)) {
                obj.receive(message);
              }

            case MULTICAST(objs):
              route.filter(function(obj) {
                return objs.has(obj);
              }).iter(function(receiver: Receiver) {
                receiver.receive(message);
              });
          }
        });
        messages = [];
      } while(nextMessages.exists(function(m) {
      return m.timing == INSTANT;
    }));
    }
  }
}

