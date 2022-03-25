package scripting;

typedef Pos = Int;

@:using(scripting.Script.TokenUtil)
enum Token {
   EOF(p:Pos);
   OPERATION(p:Pos, type:Operation);
   UNOPERATION(p:Pos, type:UnOperation);
   PAR_OPEN(p:Pos);
   PAR_CLOSE(p:Pos);
   NUMBER(p:Pos, value:Float);
   IDENTIFIER(p:Pos, id:String);
}

class TokenUtil {
   public static function getPos(token:Token) {
      return token.getParameters()[0]
   }
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

enum abstract UnOperation(Int) {
   var NOT;
   var NEGATE;
}

private class Fuse {
   private var blown:Bool = false;

   public function new() {}

   /**
      sets the state of this fuse to true and returns true
   **/
   public function blow():Bool {
      return this.blown = true;
   }

   public function isBlown():Bool {
      return this.blown;
   }
}

typedef SubParseResult = {
   var token:Token;
   var pos:Pos;
}

class Parser {
   public static function parse(script:String):Array<Token> {
      var out:Array<Token> = [];
      var pos = 0;
      var line = 1;
      while (pos < script.length) {
         var start = pos;
         var c = s.charCodeAt(pos++);
         switch (c) {
            case " ".code, "\t".code: continue
            case "\r".code, "\n".code: continue;
				default:
         }
         var d:Pos = start;
         switch (c) {
            case "(".code: out.push(PAR_OPEN(d));
            case ")".code: out.push(PAR_CLOSE(d));
            case "+".code: out.push(OPERATION(d, ADD));
            case "-".code: out.push(OPERATION(d, SUBTRACT));
            case "*".code: out.push(OPERATION(d, MULTIPLY));
            case "/".code: out.push(OPERATION(d, DIVIDE));
            case "%".code: out.push(OPERATION(d, MOD));
            case "!".code: out.push(UNOPERATION(d, NOT));
            default:
               if (c >= "0".code && c <= "9".code || c == ".".code) {
                  var dot = c == '.'.code;
                  while (pos < script.length) {
                     c = script.charCodeAt(pos);
                     if (c >= "0".code && c <= "9".code) {
                        pos++;
                     } else if (c == '.'.code && !dot) {
                        pos++;
                        dot = true;
                     } else break;
                  }
                  out.push(NUMBER())
                  //var res = Parser.parseNumber(script, pos);
                  //pos = res.pos;
                  //out.push(res.token);
               } else if (Parser.charIsIdentifierStart(c)) {
                  var res = Parser.parseIdentifier(script, pos);
                  pos = res.pos;
                  out.push(res.token);
               } else {
                  throw 'Unexpected character `${script.charAt(start)}` at position ${start}';
               }
         }
      }
      out.push(EOF(pos));
      return out;
   }

   private static function charIsIdentifierStart(c:Int) {
      if (c == "_".code) return true;
      if (c >= 'a'.code && c <= 'z'.code) return true;
      if (c >= 'A'.code && c <= 'Z'.code) return true;
      return false;
   }

   private static function parseNumber(script:String, pos):SubParseResult {
      var c = script.charCodeAt(pos);
      var dot = c == '.'.code;
      while (pos < script.length) {
         c = script.charCodeAt(pos)
      }

      return {token: IDENTIFIER(), pos: pos};
   }

   private static function parseIdentifier(script:String, pos)
}

class Script {
   public var error:Null<String> = null;
   private var isParsed:Fuse = new Fuse();
   var contents:String;
   var tokens:Array<Token> = [];

   public function new(script:String) {
      this.contents = script;
   }

   public function parse() {
      if (this.isParsed.isBlown()) return;
      this.isParsed.blow();

      var pos = 0;
      while (pos < this.contents.length) {
         var start = pos;
         var char = this.contents.charAt(pos);
         switch (char) {
            case " ":
            case "\t":
            case "\r":
            case "\n":
            case "(":
               this.tokens.push(PAR_OPEN);
            case ")":
               this.tokens.push(PAR_CLOSE);
            case "+":
               this.tokens.push(OPERATION(ADD));
            case "-":
               this.tokens.push(OPERATION(SUBTRACT));
            case "*":
               this.tokens.push(OPERATION(MULTIPLY));
            case "/":
               this.tokens.push(OPERATION(DIVIDE));
            case "%":
               this.tokens.push(OPERATION(MOD));
            case _:

         }
      }
   }
}