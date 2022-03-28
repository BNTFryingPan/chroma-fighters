package scripting;

enum abstract UnOperation(Int) {
   var NOT;
   var NEGATE;
}

enum abstract Operation(Int) {
   var MULTIPLY = 0x01;
   var DIVIDE = 0x02;
   var MOD = 0x03;
   var DIVIDE_INT = 0x04; // ?
   var ADD = 0x10;
   var SUBTRACT = 0x11;
   var MAXP = 0x20;

   public inline function getPriority():Int {
      return this >> 4;
   }

   public function toString():String {
      return 'operator 0x${StringTools.hex(this, 2)}';
   }
}
