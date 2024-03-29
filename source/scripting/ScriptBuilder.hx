package scripting;

import flixel.util.typeLimit.OneOfThree;
import scripting.Op.Operation;

typedef PosHolder = OneOfThree<ScriptToken, ScriptNode, Pos>;

/**
   the builder takes a list of tokens and builds them into nodes that will later be compiled into actions
**/
class ScriptBuilder {
   static var tokens:Array<ScriptToken>;
   static var pos:Int;
   static var len:Int;
   static var canBreak:Bool = false;
   static var canContinue:Bool = false;

   static inline function next():ScriptToken {
      return tokens[pos++];
   }

   static inline function peek(offset:Int = 0):ScriptToken {
      return tokens[pos + offset];
   }

   static inline function skip():Void {
      pos++;
   }

   static inline function error(text:String, n:PosHolder):String {
      var pos = (n is ScriptToken || n is ScriptNode) ? (cast n).getPos() : (cast n);
      return '(Script Build Error) $text on line ${pos.line} at position ${pos.linePos}';
   }

   static function ops(prev:ScriptNode, first:ScriptToken):ScriptNode {
      var nodes = [prev];
      var ops = [first];

      while (pos < len) {
         nodes.push(expr(NoOps));
         var token = peek();
         switch (token) {
            case OPERATION(_, op):
               {
                  skip();
                  ops.push(token);
               }
            default:
               break;
         }
      }
      var n = ops.length;
      for (priority in 0...Operation.MAXP.getPriority()) {
         var i = -1;
         while (++i < n)
            switch (ops[i]) {
               case OPERATION(p, type):
                  {
                     if (type.getPriority() != priority)
                        continue;
                     nodes[i] = NOperator(p, type, nodes[i], nodes[i + 1]);
                     nodes.splice(i + 1, 1);
                     ops.splice(i, 1);
                     i -= 1;
                     n -= 1;
                  }
               default:
            }
      }
      return nodes[0];
   }

   static function statement():ScriptNode {
      var token = next();
      var stat:ScriptNode;
      switch (token) {
         case RETURN(p):
            {
               stat = NReturn(p, expr(None));
            }
         case PAUSE(p):
            {
               stat = NPause(p, expr(None));
            }
         case IF(p):
            {
               var _condition = expr(None);

               var _then = statement();
               var _else = null;
               var token2 = peek();
               if (token2.match(ELSE(_))) {
                  skip();

                  _else = statement();
               }
               stat = NConditional(p, _condition, _then, _else);
            }
         case CURLY_OPEN(p):
            {
               var nodes = [];
               var closed = false;
               var token2;
               while (pos < len) {
                  token2 = peek();
                  if (token2.match(CURLY_CLOSE(_))) {
                     skip();
                     closed = true;
                     break;
                  };
                  nodes.push(statement());
               }
               if (!closed)
                  throw error('unclosed {} starting', token);
               stat = NBlock(p, nodes);
            }
         case WHILE(p):
            {
               stat = NWhile(p, expr(None), loop());
            }
         case DO(p):
            {
               var body = loop();
               // expect a WHILE
               var token2 = peek();
               if (!token2.match(WHILE(_)))
                  throw error('expected while after do', token);
               skip();
               stat = NWhileDo(p, expr(), body);
            }
         case FOR(p):
            {
               // check for (
               var hasParen:Bool = peek().match(PAR_OPEN(_));
               if (hasParen)
                  skip();
               // init
               var _init = statement();
               // condition
               var _cond = expr(None);
               if (peek().match(SEMICOLON(_)))
                  skip();
               // post-statement
               var _post = statement();
               // check for matching )
               if (hasParen)
                  if (peek().match(PAR_CLOSE(_)))
                     skip();
                  else
                     throw error('expected closing parenthesis', peek());
               stat = NFor(p, _init, _cond, _post, loop());
            }
         case BREAK(p):
            if (canBreak)
               stat = NBreak(p);
            else
               throw error('cannot break', token);
         case CONTINUE(p):
            if (canContinue)
               stat = NBreak(p);
            else
               throw error('cannot continue', token);
         case FUNCTION(p):
            {
               var name = expr(None);
               if (!name.match(NIdentifier(_, _)))
                  throw error('expected identifier for function name', token);
               var hasArgs = peek().match(PAR_OPEN(_));
               var args = [];
               if (hasArgs) {
                  skip();
                  var closed = false;

                  var argToken:ScriptToken;
                  while (pos < len) {
                     argToken = peek();
                     if (argToken == null)
                        break;
                     if (argToken.match(PAR_CLOSE(_))) {
                        skip();
                        closed = true;
                        break;
                     }
                     var nextArg = expr(NoOps);
                     if (!nextArg.match(NIdentifier(_, _)))
                        throw error('expected argument name identifier', nextArg);
                     args.push(nextArg.getParameters()[1]);

                     argToken = peek(0);
                     if (argToken.match(COMMA(_)))
                        skip();
                     else if (!argToken.match(PAR_CLOSE(_)))
                        throw error('expected closing ) or separator ,', argToken);
                  }
                  if (!closed)
                     throw error('unclosed ()', token);
               }
               var body = statement();
               stat = NFunction(p, name.getParameters()[1], args, body);
            }
         default:
            {
               pos--;
               var _expr = expr(NoOps);
               switch (_expr) {
                  case NCall(p, name, args): {
                        stat = NDiscard(p, _expr);
                     }
                  default:
                     var token2 = peek();
                     if (token2.match(SET(_))) {
                        pos++;
                        stat = NSet(token2.getPos(), _expr, expr(None));
                     } else throw error('expected a statement', _expr);
               }
            }
      }
      if (peek().match(SEMICOLON(_)))
         skip();
      return stat;
   }

   static function expr(flags:ScriptBuilderFlags = None):ScriptNode {
      var token = next();
      var exp:ScriptNode;
      switch (token) {
         case NUMBER(p, f):
            exp = NNumber(p, f);
         case IDENTIFIER(p, id):
            var next = peek();
            if (next.match(PAR_OPEN(_))) {
               pos++;
               var args = [];
               var closed = false;
               // token = peek();
               // loops over the arguments
               var token2:ScriptToken; // = peek();
               while (pos < len) {
                  token2 = peek();
                  // trace('attempting to build ${token2.getName()}');
                  if (token2 == null) {
                     // trace('null token, break;ing');
                     break;
                  }

                  // breaks when it reaches a `)`
                  if (token2.match(PAR_CLOSE(_))) {
                     pos++;
                     closed = true;
                     ///trace('par close token, break;ing');
                     break;
                  }

                  // read argument
                  args.push(expr(None));
                  // trace('pushed node ${node.getName()}');

                  // skip ,
                  token2 = peek(0);
                  if (token2.match(COMMA(_))) {
                     pos++;
                  } else if (!token2.match(PAR_CLOSE(_))) {
                     throw error('expected a `,` or `)`, instead found ${token2.getName()}', token2);
                  }
               }
               if (!closed)
                  throw error('unclosed `()`', token);

               exp = NCall(p, id, args);
            } else
               exp = NIdentifier(p, id);
         case STRING(p, value):
            exp = NString(p, value);
         case PAR_OPEN(p):
            {
               exp = expr();
               if (!next().match(PAR_CLOSE(_)))
                  throw error('unclosed () starting', token);
            }
         case OPERATION(p, type):
            {
               switch (type) {
                  case ADD:
                     exp = expr(NoOps);
                  case SUBTRACT:
                     exp = NUnOperator(p, NEGATE, expr(NoOps));
                  default:
                     exp = null;
                     throw error('unexpected operator', token);
               }
            }
         case UNOPERATION(p, type):
            exp = NUnOperator(p, type, expr(NoOps));
         default:
            exp = null;
            throw error('unexpected ${token.getName()}', token);
      }
      if (!flags.has(NoOps)) {
         var token = peek();
         switch (token) {
            case OPERATION(_, _):
               skip();
               exp = ops(exp, token);
            default:
         }
      }
      return exp;
   }

   public static function loop():ScriptNode {
      var couldBreak = canBreak;
      var couldContinue = canContinue;
      canBreak = true;
      canContinue = true;
      var stat = statement();
      canBreak = couldBreak;
      canContinue = couldContinue;
      return stat;
   }

   public static function build(tks:Array<ScriptToken>):ScriptNode {
      tokens = tks;
      pos = 0;
      len = tks.length;
      // node = null;
      canBreak = false;
      canContinue = false;
      var nodes:Array<ScriptNode> = [];

      while (pos < len - 1) {
         nodes.push(statement());
      }
      // node = ;
      return NBlock({pos: 0, linePos: 0, line: 0}, nodes);
   }
}

enum abstract ScriptBuilderFlags(Int) from Int to Int {
   var None = 0;
   var NoOps = 1;

   public function has(flag:ScriptBuilderFlags) {
      return (this & flag) == flag;
   }
}
