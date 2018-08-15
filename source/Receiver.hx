package;

using Message;

interface Receiver{
  private var messages:Array<Message>;
  // レシーバから読み出す 
  public function receive(message:Message):Void;
}
