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
   // SEMICOLON(p:Pos); // ;
   // SET(p:Pos);
   NUMBER(p:Pos, value:Float);
   IDENTIFIER(p:Pos, id:String);
   STRING(p:Pos, value:String);
   COMMA(p:Pos); // ,
   RETURN(p:Pos);
   SET(p:Pos); // =
   IF(p:Pos); // if statement
   ELSE(p:Pos);
}

class ScriptTokenUtil {
   public static function getPos(token:ScriptToken) {
      return token.getParameters()[0];
   }
}
