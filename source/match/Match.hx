package match;

import PlayerSlot;

enum GroundType {
   SOLID_GROUND;
   NOT_SOLID_GROUND;
   PLATFORM;
   NOT_GROUND; // things that cannot be stood on lmao
}

enum FighterChoice {
   NO_FIGHTER;
   MAGIC_FIGHTER;
   SCRIPTED_FIGHTER(key:NamespacedKey);
}

class FighterSelection {
   public var slot:PlayerSlotIdentifier;
   public var ready:Bool = false;
   public var choice:FighterChoice = NO_FIGHTER;

   public function new(slot:PlayerSlotIdentifier) {
      this.slot = slot;
   }
}

class Match {
   // players is an array of the player slots that will actually be in the match
   public function new(stage:String, players:Array<PlayerSlotIdentifier>) {}
}
