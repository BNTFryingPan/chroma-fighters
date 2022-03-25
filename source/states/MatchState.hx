package states;

import GameManager;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxObject;
import match.fighter.MagicFighter;
import match.stage.AbstractStage;
import states.sub.PauseScreen;

class MatchState extends BaseState {
   public var paused:Bool = false;
   public var stage:AbstractStage;
   public final stageToLoad:NamespacedKey;

   public function new(stageToLoad:NamespacedKey) {
      super();
      this.stageToLoad = stageToLoad;
   }

   override public function create() {
      super.create();

      this.persistentUpdate = true;

      PlayerSlot.PlayerBox.STATE = PlayerBoxState.IN_GAME;
      GameState.isInMatch = true;
      GameState.shouldDrawCursors = false;
      GameState.isUIOpen = false;

      FlxG.camera.scroll.x = FlxG.width * -.5;
      FlxG.camera.scroll.y = FlxG.height * -.5;

      this.stage = AbstractStage.load(this.stageToLoad);
      add(this.stage);

      for (player in PlayerSlot.players) {
         if (!player.fighterSelection.ready)
            continue;

         // TODO : change this lmao
         player.fighter = new MagicFighter(player.slot, 0, this.stage.mainGround.groundHeight - 100);
      }
   }

   public function pause(slot:PlayerSlotIdentifier) {
      if (GameState.isPaused)
         return;

      this.openSubState(new PauseScreen());
      GameState.pausedPlayer = slot;
   }

   public function unpause() {
      trace('attempt unpause');
      if (GameState.justPaused)
         return trace('just paused');
      if (!GameState.isPaused)
         return trace('not paused');
      this.closeSubState();
      GameState.pausedPlayer = null;
   }

   override public function destroy() {
      GameState.isInMatch = false;
      GameState.shouldDrawCursors = true;
      GameState.isUIOpen = true;
      super.destroy();
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
