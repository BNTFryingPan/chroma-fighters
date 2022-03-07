package states.sub;

import flixel.FlxSubState;
import states.BaseState.ChromaFightersState;

class MatchResults extends FlxSubState implements ChromaFightersState {
   public function stateId():String {
      return 'Match Results (${this.parentStateId()})';
   }

   private function parentStateId() {
      if (this._parentState is ChromaFightersState)
         return (cast this._parentState).stateId();

      return 'Non CF state';
   }
}
