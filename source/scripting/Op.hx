package scripting;

enum abstract UnOperation(Int) {
   var NOT;
   var NEGATE;
}

enum abstract Operation(Int) {
   var MULTIPLY = 0x01; // *
   var DIVIDE = 0x02; // /
   var MOD = 0x03; // % or mod
   var DIVIDE_INT = 0x04; // div
   var ADD = 0x10; // +
   var SUBTRACT = 0x11; // -
   // << >> are 0x2x
   // & | ^ are 0x3x
   var EQUALS = 0x40; // ==
   var NOT_EQUALS = 0x41; // !=
   var LESS_THAN = 0x42; // <
   var LESS_THAN_OR_EQUALS = 0x43; // <=
   var GREATER_THAN = 0x44; // >
   var GREATER_THAN_OR_EQUALS = 0x45; // >=
   

   
   var MAXP = 0x50;
   
   public inline function getPriority():Int {
      return this >> 4;
   }

   public function toString():String {
      return 'operator 0x${StringTools.hex(this, 2)}';
   }
}
