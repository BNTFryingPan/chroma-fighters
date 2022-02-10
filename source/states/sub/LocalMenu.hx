package states.sub;

import PlayerSlot;
import flixel.FlxG;
import flixel.util.FlxColor;
import inputManager.InputManager;

enum LocalMenuPage {
    CharacterSelectScreen;
    StageSelectScreen;
}

class LocalMenu extends BaseState {
    public var backButton:CustomButton;
    public var normalModeButton:CustomButton;

    //public var css_canMoveOn:Bool = false;
    //public var sss_canMoveOn:Bool = false;

    override public function create() {
        super.create();

        PlayerSlot.PlayerBox.STATE = PlayerSlot.PlayerBoxState.CHARACTER_SEL;

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

        this.normalModeButton = new CustomButton(0, 0, 'Normal Mode', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;
            
            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new CharSelectScreen(false));
            });
            //PlayerSlot.getPlayer(player).fighterSelection = !PlayerSlot.getPlayer(player).fighterSelection;
            //this.css_canMoveOn = this.areAllPlayersReady()
        });
        this.normalModeButton.screenCenter(XY);

        add(this.normalModeButton);
        add(this.backButton);
    }

    

    var page:LocalMenuPage = CharacterSelectScreen;
    var isFading:Bool = false;

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
            if (this.page == CharacterSelectScreen) {
                if (this.isFading)
                    return;
                this.isFading = true;
                FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                    FlxG.switchState(new TitleScreenState());
                });
            } else if (this.page == StageSelectScreen) {
                // TODO : return to CSS
            }
        }
    }
}
