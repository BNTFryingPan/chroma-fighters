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
    public var local_readyButton:CustomButton;
    public var local_playButton:CustomButton;

    public var css_canMoveOn:Bool = false;
    public var sss_canMoveOn:Bool = false;

    override public function create() {
        super.create();

        this.local_backButton = new CustomButton(0, -50, '<- Back', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;
            this.isFading = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> {
                FlxG.switchState(new TitleScreenState());
            });
        });
        this.local_backButton.x = 20;
        this.local_backButton.y = 20;

        this.local_readyButton = new CustomButton(0, 0, 'Ready', function(player:PlayerSlotIdentifier) {
            if (this.isFading)
                return;
            
            PlayerSlot.getPlayer(player).fighterSelection = !PlayerSlot.getPlayer(player).fighterSelection;
            this.css_canMoveOn = this.areAllPlayersReady()
        });
        this.local_readyButton.screenCenter(XY);

        this.local_playButton = new CustomButton(0, 0, 'Play', function(player:PlayerSlotIdentifier) {
            if (this.isFading || !this.css_canMoveOn)
                return;

            // todo: start match
            Main.debugDisplay.notify('Starting match');
        })

        add(this.local_readyButton);
        add(this.local_backButton);
    }

    public function areAllPlayersReady():Bool { // i hate this lmao
        return !( PlayerSlot.getPlayerArray().map( p -> { if ( p.type == NONE || p.type == CPU || !p.inputEnabled || p.fighterSelection.ready ) { return true; } return false; } ).filter( b -> { return b == false } ).length > 0 )
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
