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
   public var readyTestButton:CustomButton;
   public var continueButton:CustomButton;

   public var isFading:Bool = false;

   public function new(isOnline:Bool = false) {
      super();
      this.onlineMenu = isOnline;
   }

   override public function create() {
      super.create();

      PlayerBox.STATE = PlayerBoxState.FIGHTER_SELECT;
      GameState.shouldDrawCursors = true;

      this.backButton = new CustomButton(20, 20, '<- Back', function(player:PlayerSlotIdentifier) {
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

      this.readyTestButton = new CustomButton(0, 0, 'debug ready', function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;

         var p = PlayerSlot.getPlayer(player);
         p.fighterSelection.ready = !p.fighterSelection.ready;
      });
      this.readyTestButton.screenCenter(XY);

      this.continueButton = new CustomButton(0, 0, "fight", function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;

         if (!this.areAllPlayersReady())
            return;

         this.isFading = true;
         FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            this.onlineMenu ? FlxG.switchState(new TitleScreenState()) : FlxG.switchState(new MatchState());
         });
      });
      this.continueButton.screenCenter(XY);
      this.continueButton.y += 60;

      add(this.readyTestButton);
      add(this.continueButton);
      add(this.backButton);
   }

   public function areAllPlayersReady():Bool { // i hate this lmao; update: i think this is better...
      for (player in PlayerSlot.getPlayerArray()) {
         if (!player.isReady())
            return false;
      }
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

   override public function stateId():String {
      return 'CSS';
   }
}
