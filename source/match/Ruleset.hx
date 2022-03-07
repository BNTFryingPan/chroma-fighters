package match;

class Ruleset {
   public static final DefaultRuleset = new Ruleset(3, 7, 1);

   public var stocks:Null<Int>;
   public var time:Null<Int>;
   public var knockback:Float;

   public function new(stocks:Null<Int>=3, time:Null<Int>=7, knockback:Float=1) {
      this.stocks = stocks;
      this.time = time;
      this.knockback = knockback;
   }

   public function isValid() {
      return true;
   }
}