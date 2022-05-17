package states.sub;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import states.BaseState.ChromaFightersState;

class MatchResults extends FlxSubState implements ChromaFightersState {
   var text:FlxText;
   var name:String;

   var waittime:Float = 0;
   final maxtime:Float = 5;

   public function stateId():String {
      return 'Match Results <- ${this.parentStateId()}';
   }

   private function parentStateId() {
      if (this._parentState is ChromaFightersState)
         return (cast this._parentState).stateId();

      return 'Non CF state';
   }

   public function new(winnerName:String) {
      super();
      name = winnerName;
   }

   override public function create() {
      super.create();
      this.text = new FlxText(0, 0, 0, '${name} Wins!', 24);
      this.text.scrollFactor.set(0, 0);
      add(this.text);
      this.text.screenCenter(XY);
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      if (FlxG.timeScale > 0.1) {
         FlxG.timeScale -= elapsed;
      } else {
         if (waittime > maxtime)
            FlxG.switchState(new CharSelectScreen());
         else
            waittime += (elapsed / FlxG.timeScale);
      }
   }

   override public function destroy() {
      super.destroy();
      FlxG.timeScale = 1.0;
   }
}
