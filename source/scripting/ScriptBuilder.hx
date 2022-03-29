package scripting;

import scripting.Op.Operation;

/**
   the builder takes a list of tokens and builds them into nodes that will later be compiled into actions
**/
class ScriptBuilder {
   static var node:ScriptNode;
   static var tokens:Array<ScriptToken>;
   static var pos:Int;
   static var len:Int;

   static inline function next():ScriptToken {
      return tokens[pos++];
   }

   static inline function peek(offset:Int = 0):ScriptToken {
      return tokens[pos + offset];
   }

   static inline function skip():Void {
      pos++;
   }

   static inline function error(text:String, p:Pos):String {
      return '(Script Build Error) $text at position $p';
   }

   static function ops(first:ScriptToken) {
      var nodes = [node];
      var ops = [first];

      while (pos < len) {
         expr(NoOps);
         nodes.push(node);
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
      node = nodes[0];
   }

   static function statement() {
      var token = next();
      switch (token) {
         case RETURN(p):
            {
               expr(None);
               node = NReturn(p, node);
            }
         case IF(p):
            {
               expr(None);
               var _condition = node;
               statement();
               var _then = node;
               var _else = null;
               var token2 = peek();
               if (token2.match(ELSE(_))) {
                  skip();
                  statement();
                  _else = node;
               }
               node = NConditional(p, _condition, _then, _else);
            }
         case CURLY_OPEN(p): {
            var nodes = [];
            var closed = false;
            var token2;
            while (pos < len) {
               token2 = peek();
               if (token2.match(CURLY_CLOSE(_))) {
                  skip();
                  closed = true;
                  break;
               }
               statement();
               nodes.push(node);
            }
            if (!closed)
               throw error('unclosed {} starting', p);
            node = NBlock(p, nodes);
         }
         default:
            {
               pos--;
               expr(NoOps);
               switch (node) {
                  case NCall(p, name, args): {
                        node = NDiscard(p, node);
                     }
                  default:
                     throw error('expected a statement', node.getParameters()[0]);
               }
            }
      }
   }

   static function expr(flags:ScriptBuilderFlags = None):Void {
      var token = next();
      switch (token) {
         case NUMBER(p, f):
            node = NNumber(p, f);
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
                  expr(None);
                  args.push(node);
                  // trace('pushed node ${node.getName()}');

                  // skip ,
                  token2 = peek(0);
                  if (token2.match(COMMA(_))) {
                     pos++;
                  } else if (!token2.match(PAR_CLOSE(_))) {
                     throw error('expected a `,` or `)`, instead found ${token2.getName()}', token2.getPos());
                  }
               }
               if (!closed)
                  throw error('unclosed `()`', token.getPos());

               node = NCall(p, id, args);
            } else
               node = NIdentifier(p, id);
         case STRING(p, value):
            node = NString(p, value);
         case PAR_OPEN(p):
            {
               expr();
               if (!next().match(PAR_CLOSE(_)))
                  throw error('unclosed () starting', p);
            }
         case OPERATION(p, type):
            {
               switch (type) {
                  case ADD: expr(NoOps);
                  case SUBTRACT:
                     expr(NoOps);
                     node = NUnOperator(p, NEGATE, node);
                  default: throw error('unexpected operator', p);
               }
            }
         case UNOPERATION(p, type):
            expr(NoOps);
            node = NUnOperator(p, type, node);
         default:
            throw error('unexpected ${token.getName()}', token.getPos());
      }
      if (!flags.has(NoOps)) {
         var token = peek();
         switch (token) {
            case OPERATION(_, _):
               skip();
               ops(token);
            default:
         }
      }
   }

   public static function build(tks:Array<ScriptToken>) {
      tokens = tks;
      pos = 0;
      len = tks.length;
      node = null;
      var nodes:Array<ScriptNode> = [];

      while (pos < len - 1) {
         statement();
         nodes.push(node);
      }
      node = NBlock(0, nodes);
      return node;
   }
}

enum abstract ScriptBuilderFlags(Int) from Int to Int {
   var None = 0;
   var NoOps = 1;

   public function has(flag:ScriptBuilderFlags) {
      return (this & flag) == flag;
   }
}
