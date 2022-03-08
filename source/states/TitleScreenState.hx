package states;

import CustomButton.CustomButtonAsset;
import GameManager;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import inputManager.GenericInput;
import inputManager.InputDevice;
import inputManager.InputHelper;
import inputManager.InputManager;
import lime.system.System;
import states.sub.LocalMenu;

enum MenuScreen {
   TitleScreen;
   MainScreen;
   LocalScreen;
   VersusScreen;
   TrainingScreen;
   ExtrasScreen;
   ReplaysScreen;
   OnlineScreen;
   SettingsScreen;
   ControlsScreen;
   GeneralSettingsScreen;
}

class TitleScreenState extends BaseState {
   var pressStartText:FlxText;

   var logoSprite:FlxSprite;

   var main_localButton:CustomButton;
   var main_onlineButton:CustomButton;
   var main_settingsButton:CustomButton;
   var main_exitButton:CustomButton;

   var local_versusButton:CustomButton;
   var local_trainingButton:CustomButton;
   var local_extrasButton:CustomButton;
   var local_backButton:CustomButton;

   var extras_replaysButton:CustomButton;
   var extras_backButton:CustomButton;

   var settings_controlsButton:CustomButton;
   var settings_generalButton:CustomButton;
   var settings_resetAllDataButton:CustomButton;
   var settings_backButton:CustomButton;

   public static var currentScreen:MenuScreen = TitleScreen;

   public static var pastStartScreen:Bool = false;
   private static var hasEverPassedStartScreenThisSession:Bool = false;
   private static var shouldShowTitleScreenAnyways:Bool = false;

   private var hasPressedButtons:Bool = false;

   private var isFading:Bool = false;

   override public function create() {
      super.create();

      PlayerSlot.PlayerBox.STATE = PlayerBoxState.HIDDEN;
      GameState.shouldDrawCursors = true;

      this.logoSprite = new FlxSprite(0, 40);
      this.logoSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace('images/ui/logo_full')));
      this.logoSprite.graphic.persist = true;
      this.logoSprite.screenCenter(X);

      this.pressStartText = new FlxText(0, 400, 0, "Press A+S or LB+RB");
      this.pressStartText.screenCenter(X);

      this.main_localButton = new CustomButton(0, -50, null, function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;
         this.isFading = true;
         FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
            FlxG.switchState(new LocalMenu());
         });
      }, CustomButtonAsset.Main_Local);
      this.main_localButton.screenCenter(X);

      this.main_onlineButton = new CustomButton(0, -100, null, function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;
         Main.log(player + ": online button");
      }, CustomButtonAsset.Main_Online);
      this.main_onlineButton.screenCenter(X);
      this.main_onlineButton.x -= 40;

      this.main_settingsButton = new CustomButton(0, -150, null, function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;
         Main.log(player + ": settings button");
      }, CustomButtonAsset.Main_Settings);
      this.main_settingsButton.screenCenter(X);
      this.main_settingsButton.x += 104;

      this.main_exitButton = new CustomButton(0, -200, null, function(player:PlayerSlotIdentifier) {
         if (this.isFading)
            return;
         // clean up any save data first.
         // might want to call a global exit function that does that
         System.exit(0);
      }, CustomButtonAsset.Main_Exit);
      this.main_exitButton.screenCenter(X);
      this.main_exitButton.x += 80;

      add(this.pressStartText);
      add(this.logoSprite);
      add(this.main_localButton);
      // add(this.main_onlineButton);
      add(this.main_settingsButton);
      add(this.main_exitButton);

      if (TitleScreenState.hasEverPassedStartScreenThisSession && !TitleScreenState.shouldShowTitleScreenAnyways) {
         this.main_localButton.y = 220;
         this.main_onlineButton.y = 295;
         this.main_settingsButton.y = 295;
         this.main_exitButton.y = 370;
         this.pressStartText.y = 500;
      }

      if (TitleScreenState.shouldShowTitleScreenAnyways) {
         TitleScreenState.shouldShowTitleScreenAnyways = false;
         TitleScreenState.pastStartScreen = false;
      }

      if (!TitleScreenState.hasEverPassedStartScreenThisSession) {
         MenuMusicManager.load();
      }
   }

   private function movedOn() {
      TitleScreenState.pastStartScreen = true;
      TitleScreenState.hasEverPassedStartScreenThisSession = true;
      InputManager.enabled = true;
   }

   private function moveOn() {
      this.hasPressedButtons = true;
      FlxTween.tween(this.main_localButton, {y: 220}, 1, {
         onComplete: (t) -> {
            this.movedOn();
         }
      });
      FlxTween.tween(this.main_onlineButton, {y: 295}, 1);
      FlxTween.tween(this.main_settingsButton, {y: 295}, 1);
      FlxTween.tween(this.main_exitButton, {y: 370}, 1);
      FlxTween.tween(this.pressStartText, {y: 500}, 1);
   }

   override public function update(elapsed:Float) {
      Main.debugDisplay.rightAppend += '\n${TitleScreenState.pastStartScreen ? 'P' : 'p'}${TitleScreenState.hasEverPassedStartScreenThisSession ? 'S' : 's'}${this.hasPressedButtons ? 'B' : 'b'}';

      if (!this.isFading) {
         if (!TitleScreenState.pastStartScreen && !this.hasPressedButtons) {
            var startingGamepads = FlxG.gamepads.getActiveGamepads()
               .filter(gamepad -> (gamepad.pressed.LEFT_SHOULDER && gamepad.pressed.RIGHT_SHOULDER)
                  || (gamepad.pressed.RIGHT_TRIGGER_BUTTON && gamepad.pressed.LEFT_TRIGGER_BUTTON));
            if (startingGamepads.length > 0) {
               if (!TitleScreenState.hasEverPassedStartScreenThisSession) {
                  PlayerSlot.getPlayer(P1).setNewInput(ControllerInput, startingGamepads[0]);
               }

               this.moveOn();
            } else if (FlxG.keys.pressed.A && FlxG.keys.pressed.S) {
               if (!TitleScreenState.hasEverPassedStartScreenThisSession) {
                  PlayerSlot.getPlayer(P1).setNewInput(KeyboardInput, Keyboard);
                  // PlayerSlot.getPlayer(P2).setNewInput(KeyboardAndMouseInput, Keyboard);
               } else
                  Main.skipKeyboardModeToggleCheckNextUpdate = true;
               this.moveOn();
            }
         } else if (!TitleScreenState.pastStartScreen && this.hasPressedButtons) {
            this.main_localButton.y = 220;
            this.main_onlineButton.y = 295;
            this.main_settingsButton.y = 295;
            this.main_exitButton.y = 370;
            this.pressStartText.y = 500;
            this.movedOn();
         } else if (TitleScreenState.pastStartScreen) {
            if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
               TitleScreenState.shouldShowTitleScreenAnyways = true;
               FlxG.resetState();
            }
         }
      }

      super.update(elapsed);
   }

   override public function stateId():String {
      return 'TitleScreen';
   }
}
