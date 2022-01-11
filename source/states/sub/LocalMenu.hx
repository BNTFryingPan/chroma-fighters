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
    public var local_backButton:CustomButton;

    override public function create() {
        super.create();

        this.local_backButton = new CustomButton(0, -50, '<- Back', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;
            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new LocalMenu());
            });
        });
        this.local_backButton.x = 20;
        this.local_backButton.y = 20;

        add(this.local_backButton);
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
