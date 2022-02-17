package states;

import GameManager;
import flixel.FlxG;
import flixel.FlxObject;
import match.Stage;
import match.fighter.MagicFighter;

class MatchState extends BaseState {
   public var paused:Bool = false;
   public var stage:Stage;

   override public function create() {
      super.create();

      PlayerSlot.PlayerBox.STATE = PlayerBoxState.IN_GAME;
      GameState.isInMatch = true;
      GameState.shouldDrawCursors = false;
      GameState.isUIOpen = false;

      FlxG.camera.scroll.x = FlxG.width * -.5;
      FlxG.camera.scroll.y = FlxG.height * -.5;

      this.stage = new Stage();
      add(this.stage);

      for (player in PlayerSlot.getPlayerArray(true)) {
         if (!player.fighterSelection.ready)
            continue;

         // TODO : change this lmao
         player.fighter = cast add(new MagicFighter(player.slot, 0, this.stage.mainGround.groundHeight - 20));
      }
   }

   // @:access(flixel.FlxObject)
   // override public function update(elapsed:Float) {
   // super.update(elapsed);
   // for (player in PlayerSlot.getPlayerArray(true)) {
   // if (player.fighter == null)
   // continue;
   // FlxG.collide(player.fighter, this.stage.mainGround);
   // }
   // super.update(elapsed);
   // }

   override public function stateId():String {
      return 'MatchState';
   }
}
