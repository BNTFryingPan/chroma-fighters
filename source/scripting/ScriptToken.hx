package scripting;

import scripting.Op;

@:using(scripting.ScriptToken.ScriptTokenUtil)
enum ScriptToken {
   EOF(p:Pos); // end of file
   OPERATION(p:Pos, type:Operation); // +, -. *, /, %, div, mod
   UNOPERATION(p:Pos, type:UnOperation); // !bool, -num
   PAR_OPEN(p:Pos); // (
   PAR_CLOSE(p:Pos); // )
   CURLY_OPEN(p:Pos); // {
   CURLY_CLOSE(p:Pos); // }
   // SQUARE_OPEN(p:Pos); // [
   // SQUARE_CLSOE(p:Pos); // ]
   SEMICOLON(p:Pos); // ;
   // SET(p:Pos);
   NUMBER(p:Pos, value:Float);
   BOOLEAN(p:Pos, value:Bool);
   IDENTIFIER(p:Pos, id:String);
   STRING(p:Pos, value:String);
   // TYPEOF(p:Pos);
   PAUSE(p:Pos); // pause
   COMMA(p:Pos); // ,
   RETURN(p:Pos); // return
   SET(p:Pos); // =
   IF(p:Pos); // if statement
   ELSE(p:Pos); // else
   WHILE(p:Pos); // while
   DO(p:Pos); // while expr do stat
   FOR(p:Pos); // for
   BREAK(p:Pos); // break
   CONTINUE(p:Pos); // continue
   FUNCTION(p:Pos); // function
}

class ScriptTokenUtil {
   public static function getPos(token:ScriptToken) {
      return token.getParameters()[0];
   }

   public static function getTokenString(token:ScriptToken):String {
      return switch (token) {
         case EOF(_):
            '<eof>';
         case OPERATION(_, _):
            'bin_op';
         case UNOPERATION(_, _):
            'un_op';
         case PAR_OPEN(_):
            '(';
         case PAR_CLOSE(_):
            ')';
         case CURLY_OPEN(_):
            '\n{';
         case CURLY_CLOSE(_):
            '}';
         case NUMBER(_, _):
            'Number';
         case IDENTIFIER(_, _):
            'Identifier';
         case STRING(_, _):
            'String';
         case COMMA(_):
            ',';
         case RETURN(_):
            '\nreturn';
         case SET(_):
            '=';
         case IF(_):
            '\nif';
         case ELSE(_):
            '\nelse';
         default:
            token.getName();
      }
   }

   public static function debugPrint(token:ScriptToken):String {
      var params = token.getParameters();
      var name = token.getTokenString();
      var str = '';
      if (name.charCodeAt(0) == '\n'.code) {
         str += '\n';
         name = name.substr(1);
      }
      str += '[${params.shift()}]${name}';
      if (params.length > 0) {
         str += '<${params.join(",")}>';
      };
      return str;
   }
}
