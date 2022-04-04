package scripting;

typedef SubParseResult = {
   var token:ScriptToken;
   var pos:Pos;
}

/**
   the parser takes the raw text of a script and turns it into a list of tokens to later be built into nodes.
**/
class ScriptParser {
   static inline function error(text:String, pos:Pos):String {
      return '(Script Parse Error): $text on line ${pos.line} position ${pos.linePos}';
   }

   // static var pos = 0;
   // static var line = 0;
   // static var linepos = 0;

   public static function parse(script:String):Array<ScriptToken> {
      var out:Array<ScriptToken> = [];
      var pos:Int = 0;
      var line:Int = 0;
      var linepos:Int = 0;
      while (pos < script.length) {
         var start:Pos = {pos: pos, line: line, linePos: linepos++};
         var c = script.charCodeAt(pos++);
         switch (c) {
            case " ".code, "\t".code:
               continue;
            case "\r".code:
               if (script.charCodeAt(pos) == '\n'.code)
                  pos++;
               line++;
               linepos = 0;
            case "\n".code:
               line++;
               linepos = 0;
               continue;
            default:
         }
         var d:Pos = start;
         switch (c) {
            case ';'.code:
               out.push(SEMICOLON(d));
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
               if (script.charCodeAt(pos) == '*'.code) {
                  out.push(OPERATION(d, EXPONENT));
               } else {
                  out.push(OPERATION(d, MULTIPLY));
               }
            case "%".code:
               out.push(OPERATION(d, MOD));
            case '^'.code:
               out.push(OPERATION(d, BIT_XOR));
            case '/'.code:
               switch (script.charCodeAt(pos)) {
                  case '/'.code:
                     while (pos < script.length) {
                        var nl = script.charCodeAt(pos++);
                        if (nl == '\r'.code) {
                           if (script.charCodeAt(pos) == '\n'.code)
                              pos++;
                           line++;
                           linepos = 0;
                           break;
                        } else if (nl == '\n'.code) {
                           pos++;
                           line++;
                           linepos = 0;
                        }
                     }
                  case '*'.code:
                     pos++;
                     linepos++;
                     while (pos < script.length) {
                        switch (script.charCodeAt(pos++)) {
                           case '\r'.code:
                              if (script.charCodeAt(pos) == '\n'.code)
                                 pos++;
                              line++;
                              linepos = 0;
                           case '\n'.code:
                              line++;
                              linepos = 0;
                           case '*'.code:
                              if (script.charCodeAt(pos) == '/'.code) {
                                 pos += 2;
                                 linepos += 2;
                                 break;
                              }
                        }
                     }
                  default:
                     out.push(OPERATION(d, DIVIDE));
               }
            case '|'.code:
               if (script.charCodeAt(pos) == '|'.code) {
                  pos++;
                  linepos++;
                  out.push(OPERATION(d, OR));
               } else
                  out.push(OPERATION(d, BIT_OR));
            case '&'.code:
               if (script.charCodeAt(pos) == '&'.code) {
                  pos++;
                  linepos++;
                  out.push(OPERATION(d, AND));
               } else
                  out.push(OPERATION(d, BIT_AND));
            case "!".code:
               if (script.charCodeAt(pos) == '='.code) {
                  pos++;
                  linepos++;
                  out.push(OPERATION(d, NOT_EQUALS));
               } else
                  out.push(UNOPERATION(d, NOT));
            case "=".code:
               if (script.charCodeAt(pos) == '='.code) {
                  pos++;
                  linepos++;
                  out.push(OPERATION(d, EQUALS));
               } else
                  out.push(SET(d));
            case ">".code:
               linepos++;
               switch (script.charCodeAt(pos++)) {
                  case '='.code:
                     out.push(OPERATION(d, GREATER_THAN_OR_EQUALS));
                  case '>'.code:
                     out.push(OPERATION(d, BIT_SHIFT_RIGHT));
                  default:
                     pos--;
                     out.push(OPERATION(d, GREATER_THAN));
               }
            case "<".code:
               linepos++;
               switch (script.charCodeAt(pos++)) {
                  case '='.code:
                     out.push(OPERATION(d, LESS_THAN_OR_EQUALS));
                  case '>'.code:
                     out.push(OPERATION(d, BIT_SHIFT_LEFT));
                  default:
                     pos--;
                     out.push(OPERATION(d, LESS_THAN));
               }
            case "'".code | '"'.code:
               while (pos < script.length) {
                  var n = script.charCodeAt(pos++);
                  if (n == c && script.charCodeAt(pos - 2) != '\\'.code)
                     break;
                  else if (n == '\r'.code) {
                     if (script.charCodeAt(pos) == '\n'.code)
                        pos++;
                     line++;
                     linepos = 0;
                  } else if (n == '\n'.code) {
                     line++;
                     linepos = 0;
                  } else {
                     linepos++;
                  }
               }
               if (pos < script.length) {
                  linepos++;
                  out.push(STRING(d, script.substring(start.pos + 1, pos++)));
               } else
                  throw error('String is not closed, starting', start);
            default:
               {
                  if (c >= "0".code && c <= "9".code || c == ".".code) {
                     var dot = c == '.'.code;
                     while (pos < script.length) {
                        c = script.charCodeAt(pos);
                        if (c >= "0".code && c <= "9".code) {
                           linepos++;
                           pos++;
                        } else if (c == '.'.code && !dot) {
                           pos++;
                           dot = true;
                        } else
                           break;
                     }
                     out.push(NUMBER(d, Std.parseFloat(script.substring(start.pos, pos))));
                     // var res = Parser.parseNumber(script, pos);
                     // pos = res.pos;
                     // out.push(res.token);
                  } else if (ScriptParser.charIsIdentifierStart(c)) {
                     while (pos < script.length) {
                        c = script.charCodeAt(pos);
                        if (ScriptParser.charIsIdentifierChar(c)) {
                           pos++;
                           linepos++;
                        } else
                           break;
                     }
                     var name = script.substring(start.pos, pos);
                     switch (name) {
                        case 'mod': out.push(OPERATION(d, MOD));
                        case 'div': out.push(OPERATION(d, DIVIDE_INT));
                        case 'return': out.push(RETURN(d));
                        case 'if': out.push(IF(d));
                        case 'else': out.push(ELSE(d));
                        case 'while': out.push(WHILE(d));
                        case 'do': out.push(DO(d));
                        case 'for': out.push(FOR(d));
                        case 'break': out.push(BREAK(d));
                        case 'continue': out.push(CONTINUE(d));
                        case 'wait': out.push(CONTINUE(d)); // case 'typeof': out.push(TYPEOF(d));
                        case 'pause': out.push(PAUSE(d));
                        default: out.push(IDENTIFIER(d, name));
                     }
                     // var res = Parser.parseIdentifier(script, pos);
                     // pos = res.pos;
                     // out.push(res.token);
                  } else {
                     throw error('Unexpected character `${script.charAt(start.pos)}`', start);
                  }
               }
         }
      }
      out.push(EOF({pos: pos, line: line, linePos: linepos}));
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
   /*private static function parseNumber(script:String, pos):SubParseResult {
         var c = script.charCodeAt(pos);
         var dot = c == '.'.code;
         while (pos < script.length) {
            c = script.charCodeAt(pos);
         }

         return {token: NUMBER(pos, 1), pos: pos};
      }

      private static function parseIdentifier(script:String, pos):SubParseResult {
         return {token: IDENTIFIER(pos, 'lol'), pos: pos}
   }*/
}
