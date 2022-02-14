package states.sub;

import GameManager;
import PlayerSlot;
import flixel.FlxG;
import flixel.util.FlxColor;
import inputManager.InputEnums;
import inputManager.InputManager;

class CharSelectScreen extends BaseState {
   public var onlineMenu:Bool = false;
   public var backButton:CustomButton;

   public var isFading:Bool = false;

   public function new(isOnline:Bool = false) {
      super();
      this.onlineMenu = isOnline;
   }

   override public function create() {
      super.create();

      PlayerBox.STATE = PlayerBoxState.FIGHTER_SELECT;

      this.backButton = new CustomButton(0, -50, '<- Back', function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;
         this.isFading = true;
         FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            if (this.onlineMenu)
               FlxG.switchState(new TitleScreenState());
            else
               FlxG.switchState(new LocalMenu());
         });
      });
      this.backButton.x = 20;
      this.backButton.y = 20;

      add(this.backButton);
   }

   private function _isPlayerReady(player:PlayerSlot):Bool {
      if (player.type == NONE)
         return true;
      if (player.type == CPU)
         return true; // TODO : check if a player is picking the CPUs character
      if (!player.input.inputEnabled)
         return true;
      if (player.fighterSelection.ready)
         return true;
      return false;
   }

   public function areAllPlayersReady():Bool { // i hate this lmao; update: i think this is better...
      var mappedPlayers = PlayerSlot.getPlayerArray().map(this._isPlayerReady);
      var unreadyPlayers = mappedPlayers.filter(r -> {
         return r == false;
      });
      if (unreadyPlayers.length > 0)
         return false;
      return true;
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
         if (this.isFading)
            return;
         this.isFading = true;
         return FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            FlxG.switchState(new TitleScreenState());
         });
      }

      if (InputManager.anyPlayerPressingAction(Action.MENU_BUTTON) && this.areAllPlayersReady()) {
         if (this.isFading)
            return;
         /*this.isFading = true;
            return FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new TitleScreenState());
         });*/
         Main.debugDisplay.notify('moving to SSS'); // will probably skip sss for now and go to testing stage because
      }
   }
}
