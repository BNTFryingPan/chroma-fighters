package states.sub;

import GameManager;
import PlayerSlot;
import flixel.FlxG;
import flixel.util.FlxColor;
import inputManager.InputManager;

class LocalMenu extends BaseState {
    public var backButton:CustomButton;
    public var normalModeButton:CustomButton;

    // public var css_canMoveOn:Bool = false;
    // public var sss_canMoveOn:Bool = false;

    override public function create() {
        super.create();

        PlayerSlot.PlayerBox.STATE = PlayerBoxState.FIGHTER_SELECT;

        this.backButton = new CustomButton(0, -50, '<- Back', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;
            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new TitleScreenState());
            });
        });
        this.backButton.x = 20;
        this.backButton.y = 20;

        this.normalModeButton = new CustomButton(0, 0, 'Fight', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;

            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new CharSelectScreen(false));
            });
            // PlayerSlot.getPlayer(player).fighterSelection = !PlayerSlot.getPlayer(player).fighterSelection;
            // this.css_canMoveOn = this.areAllPlayersReady()
        });
        this.normalModeButton.screenCenter(XY);

        add(this.normalModeButton);
        add(this.backButton);
    }

    var isFading:Bool = false;

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
            if (this.isFading)
                return;
            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new TitleScreenState());
            });
        }
    }
}
