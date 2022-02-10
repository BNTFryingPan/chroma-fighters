package match.fighter;

class MagicFighterMoves extends FighterMoves {
    private final moves:Map<String, Function> = [
        'taunt' => this.taunt,
    ];

    public function new(fighter:MagicFighter) {
        super(fighter);
    }

    public function taunt() {
        Main.log('magic taunt!');
        return SUCCESS;
    }
}

class MagicFighter extends AbstractFighter {
    public override function createFighterMoves() {
        this.moves = new MagicFighterMoves(this);
    }
}