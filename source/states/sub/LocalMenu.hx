package states.sub;

import flixel.FlxG;
import inputManager.InputManager;

enum LocalMenuState {
    CharacterSelectScreen;
    StageSelectScreen;
}

class LocalMenu extends BaseState {
    override public function create() {
        super.create();
    }

    var subState:LocalMenuState = CharacterSelectScreen;

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
            if (this.subState == CharacterSelectScreen) {
                FlxG.switchState(new TitleScreenState());
            } else if (this.subState == StageSelectScreen) {
                // TODO : return to CSS
            }
        }
    }
}
