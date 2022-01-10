package states.sub;

import flixel.FlxG;
import inputManager.InputManager;

class LocalMenu extends BaseState {
    override public function create() {
        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (InputManager.anyPlayerPressingAction(MENU_CANCEL)) {
            FlxG.switchState(new TitleScreenState());
        }
    }
}
