package scripting;

typedef SubParseResult = {
   var token:ScriptToken;
   var pos:Pos;
}

/**
   the parser takes the raw text of a script and turns it into a list of tokens to later be built into nodes.
**/
class ScriptParser {
   static inline function error(text:String, pos:Int):String {
      return '(Script Parse Error): $text at position $pos';
   }

   public static function parse(script:String):Array<ScriptToken> {
      var out:Array<ScriptToken> = [];
      var pos = 0;
      //var line = 1;
      while (pos < script.length) {
         var start = pos;
         var c = script.charCodeAt(pos++);
         switch (c) {
            case " ".code, "\t".code:
               continue;
            case "\r".code, "\n".code:
               //line++;
               continue;
            default:
         }
         var d:Pos = start;
         switch (c) {
            case "(".code:
               out.push(PAR_OPEN(d));
            case ")".code:
               out.push(PAR_CLOSE(d));
            case "{".code:
               out.push(CURLY_OPEN(d));
            case "}".code:
               out.push(CURLY_CLOSE(d));
            case ','.code:
               out.push(COMMA(d));
            case "+".code:
               out.push(OPERATION(d, ADD));
            case "-".code:
               out.push(OPERATION(d, SUBTRACT));
            case "*".code:
               out.push(OPERATION(d, MULTIPLY));
            case "/".code:
               out.push(OPERATION(d, DIVIDE));
            case "%".code:
               out.push(OPERATION(d, MOD));
            case "!".code:
               out.push(UNOPERATION(d, NOT));
            case "=".code:
               out.push(SET(d));
            case "'".code | '"'.code:
               while (pos < script.length) {
                  if (script.charCodeAt(pos) == c)
                     break;
                  pos++;
               }
               if (pos < script.length) {
                  out.push(STRING(d, script.substring(start + 1, pos++)));
               } else
                  throw error('String is not closed, starting', start);
            default:
               {
                  if (c >= "0".code && c <= "9".code || c == ".".code) {
                     var dot = c == '.'.code;
                     while (pos < script.length) {
                        c = script.charCodeAt(pos);
                        if (c >= "0".code && c <= "9".code) {
                           pos++;
                        } else if (c == '.'.code && !dot) {
                           pos++;
                           dot = true;
                        } else
                           break;
                     }
                     out.push(NUMBER(d, Std.parseFloat(script.substring(start, pos))));
                     // var res = Parser.parseNumber(script, pos);
                     // pos = res.pos;
                     // out.push(res.token);
                  } else if (ScriptParser.charIsIdentifierStart(c)) {
                     while (pos < script.length) {
                        c = script.charCodeAt(pos);
                        if (ScriptParser.charIsIdentifierChar(c)) {
                           pos++;
                        } else
                           break;
                     }
                     var name = script.substring(start, pos);
                     switch (name) {
                        case 'mod': out.push(OPERATION(d, MOD));
                        case 'div': out.push(OPERATION(d, DIVIDE_INT));
                        case 'return': out.push(RETURN(d));
                        case 'if': out.push(IF(d));
                        case 'else': out.push(ELSE(d));
                        default: out.push(IDENTIFIER(d, name));
                     }
                     // var res = Parser.parseIdentifier(script, pos);
                     // pos = res.pos;
                     // out.push(res.token);
                  } else {
                     throw error('Unexpected character `${script.charAt(start)}`', start);
                  }
               }
         }
      }
      out.push(EOF(pos));
      return out;
   }

   private static function charIsIdentifierStart(c:Int):Bool {
      if (c == "_".code)
         return true;
      if (c >= 'a'.code && c <= 'z'.code)
         return true;
      if (c >= 'A'.code && c <= 'Z'.code)
         return true;
      return false;
   }

   private static function charIsIdentifierChar(c:Int):Bool {
      if (charIsIdentifierStart(c))
         return true;
      if (c >= '0'.code && c <= '9'.code)
         return true;
      return false;
   }

   private static function parseNumber(script:String, pos):SubParseResult {
      var c = script.charCodeAt(pos);
      var dot = c == '.'.code;
      while (pos < script.length) {
         c = script.charCodeAt(pos);
      }

      return {token: NUMBER(pos, 1), pos: pos};
   }

   private static function parseIdentifier(script:String, pos):SubParseResult {
      return {token: IDENTIFIER(pos, 'lol'), pos: pos}
   }
}
