package match;

class FighterSelection {
    public var slot:PlayerSlotIdentifier;
    public var ready:Bool = false;

    public function new(slot:PlayerSlotIdentifier) {
        this.slot = slot;
    }

    public function setFighterSelection() {}
}

class Match {
    // players is an array of the player slots that will actually be in the match
    public function new(stage:String, players:Array<PlayerSlotIdentifier>) {
        
    }
}
