package states;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import inputManager.GenericInput;
import inputManager.InputEnums;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputTypes;
import lime.system.System;

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

    private var hasPressedButtons:Bool = false;

    override public function create() {
        super.create();

        this.pressStartText = new FlxText(0, 400, 0, "Press A+S or LB+RB");
        this.pressStartText.screenCenter(X);

        this.main_localButton = new CustomButton(0, -50, "Local", function(player:PlayerSlotIdentifier) {
            Main.log(player + ": local button");
        });
        this.main_localButton.screenCenter(X);

        this.main_onlineButton = new CustomButton(0, -100, "Online (coming soon?)", function(player:PlayerSlotIdentifier) {
            Main.log(player + ": online button");
        });
        this.main_onlineButton.screenCenter(X);

        this.main_settingsButton = new CustomButton(0, -150, "Settings", function(player:PlayerSlotIdentifier) {
            Main.log(player + ": settings button");
        });
        this.main_settingsButton.screenCenter(X);

        this.main_exitButton = new CustomButton(0, -200, "Quit", function(player:PlayerSlotIdentifier) {
            System.exit(0);
        });
        this.main_exitButton.screenCenter(X);

        add(this.pressStartText);
        add(this.main_localButton);
        add(this.main_onlineButton);
        add(this.main_settingsButton);
        add(this.main_exitButton);

        if (TitleScreenState.hasEverPassedStartScreenThisSession) {
            this.main_localButton.y = 100;
            this.main_onlineButton.y = 150;
            this.main_settingsButton.y = 200;
            this.main_exitButton.y = 250;
            this.pressStartText.y = 500;
        }
    }

    private function movedOn() {
        TitleScreenState.pastStartScreen = true;
        TitleScreenState.hasEverPassedStartScreenThisSession = true;
        InputManager.enabled = true;
    }

    private function moveOn() {
        this.hasPressedButtons = true;
        FlxTween.tween(this.main_localButton, {y: 100}, 1, {
            onComplete: (t) -> {
                this.movedOn();
            }
        });
        FlxTween.tween(this.main_onlineButton, {y: 150}, 1);
        FlxTween.tween(this.main_settingsButton, {y: 200}, 1);
        FlxTween.tween(this.main_exitButton, {y: 250}, 1);
        FlxTween.tween(this.pressStartText, {y: 500}, 1);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

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
                if (!TitleScreenState.hasEverPassedStartScreenThisSession)
                    PlayerSlot.getPlayer(P1).setNewInput(KeyboardInput, Keyboard);
                this.moveOn();
            }
        } else if (!TitleScreenState.pastStartScreen && this.hasPressedButtons) {
            this.main_localButton.y = 100;
            this.main_onlineButton.y = 150;
            this.main_settingsButton.y = 200;
            this.main_exitButton.y = 250;
            this.pressStartText.y = 500;
            this.movedOn();
        } else if (TitleScreenState.pastStartScreen) {
            if (InputManager.getPlayerArray().filter(player -> InputHelper.isPressed(player.getCancel())).length > 0) {
                this.pressStartText.y = 400;
                this.main_localButton.y = -50;
                this.main_onlineButton.y = -100;
                this.main_settingsButton.y = -150;
                this.main_exitButton.y = -200;
                TitleScreenState.pastStartScreen = false;
                this.hasPressedButtons = false;
            }
        }
    }
}
