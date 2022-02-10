package states;

class MatchState extends BaseState {
    public var paused:Bool = false;
    public var stage:Stage;

    override public function create() {
        super.create();

        PlayerSlot.PlayerBox.STATE = PlayerSlot.PlayerBoxState.MATCH;
    }
}