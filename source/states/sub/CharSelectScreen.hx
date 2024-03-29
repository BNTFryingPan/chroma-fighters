package states.sub;

import GameManager;
import MenuMusicManager.MenuMusicState;
import PlayerSlot;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import inputManager.Action;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputState;

class CharSelectScreen extends BaseState {
   public var onlineMenu:Bool = false;
   public var backButton:CustomButton;
   public var readyTestButton:CustomButton;
   public var continueButton:CustomButton;
   public var backProgress:FlxBar;
   public var cancelHoldProgress(get, never):Float;

   public function get_cancelHoldProgress():Float {
      var max:Float = 0;
      for (p in PlayerSlot.players) {
         if (p.cancelHoldTime > max)
            max = p.cancelHoldTime;
      }
      return max;
   }

   public var isFading:Bool = false;

   public function new(isOnline:Bool = false) {
      super();
      this.onlineMenu = isOnline;
   }

   override public function create() {
      super.create();

      PlayerBox.STATE = PlayerBoxState.FIGHTER_SELECT;
      MenuMusicManager.musicState = MenuMusicState.FIGHTER_SELECT;
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

      this.backProgress = new FlxBar(20, 50, LEFT_TO_RIGHT, Std.int(backButton.width), Std.int(backButton.height), this, 'cancelHoldProgress', 0, 3);

      this.readyTestButton = new CustomButton(0, 0, 'Martha', function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;

         var p = PlayerSlot.getPlayer(player);
         p.heldCoin = null;
         p.fighterSelection.ready = !p.fighterSelection.ready;
      });
      this.readyTestButton.screenCenter(XY);

      this.continueButton = new CustomButton(0, 0, "Fight!", function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;

         if (!this.areAllPlayersReady())
            return;

         this.isFading = true;
         FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            this.onlineMenu ? FlxG.switchState(new TitleScreenState()) : FlxG.switchState(new MatchState(new NamespacedKey('cf_stages', 'chroma_fracture')));
         });
      });
      this.continueButton.screenCenter(XY);
      this.continueButton.y += 50;

      add(this.readyTestButton);
      add(this.continueButton);
      add(this.backButton);
      add(this.backProgress);
   }

   public function areAllPlayersReady():Bool { // i hate this lmao; update: i think this is better... update 2: this looks fine i think; update 3: this is fine now
      for (p in PlayerSlot.players)
         if (!p.isReady())
            return false;
      return true;
      // return [for (p in PlayerSlot.players) if (!p.isReady()) true].length > 0;
      //   if (!player.isReady())
      //      return false;
      // return true;
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      for (player in PlayerSlot.players) {
         if (player.isReady() && player.input.getCancel() == JUST_PRESSED) {
            player.fighterSelection.ready = false;
            player.heldCoin = player.slot;
         } else if (!this.isFading && InputHelper.isPressed(player.input.getCancel())) {
            if (player.cancelHoldTime >= 1.5) {
               player.cancelHoldTime = 0;
               this.isFading = true;
               return FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                  FlxG.switchState(new TitleScreenState());
               });
            }
            player.cancelHoldTime += elapsed;
         } else {
            player.cancelHoldTime = 0;
         }
      }

      /*if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
         if (this.isFading)
            return;
         this.isFading = true;
         return FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            FlxG.switchState(new TitleScreenState());
         });
      }*/

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
