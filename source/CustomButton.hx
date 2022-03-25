package;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.typeLimit.OneOfThree;
import inputManager.InputManager;

enum abstract CustomButtonAsset(String) to String {
   var Main_Local = "images/ui/button/local";
   var Main_Online = "images/ui/button/online";
   var Main_Settings = "images/ui/button/settings";
   var Main_Exit = "images/ui/button/exit";
   var General_Back = "images/ui/button/back";
}

typedef CustomButtonContent = OneOfThree<CustomButtonAsset, String, NamespacedKey>;

class CustomButton extends FlxButton {
   public var cursorOnDown:Null<PlayerSlotIdentifier->Void> = null;
   public var cursorOnUp:Null<PlayerSlotIdentifier->Void> = null;
   public var cursorOnOver:Null<PlayerSlotIdentifier->Void> = null;
   public var cursorOnOut:Null<PlayerSlotIdentifier->Void> = null;

   private var currentHoveredCursors:Map<PlayerSlotIdentifier, Bool> = [
      P1 => false,
      P2 => false,
      P3 => false,
      P4 => false,
      P5 => false,
      P6 => false,
      P7 => false,
      P8 => false
   ];

   private var currentClickedCursors:Map<PlayerSlotIdentifier, Bool> = [
      P1 => false,
      P2 => false,
      P3 => false,
      P4 => false,
      P5 => false,
      P6 => false,
      P7 => false,
      P8 => false
   ];

   private function getRealHovered():Map<PlayerSlotIdentifier, Bool> {
      return [
         for (player in PlayerSlot.players)
            player.slot => (this.currentHoveredCursors.get(player.slot) && player.visible)
      ];
   }

   private function getRealClicked():Map<PlayerSlotIdentifier, Bool> {
      return [
         for (player in PlayerSlot.players)
            player.slot => (this.currentClickedCursors.get(player.slot) && player.visible)
      ];
   }

   public function new(x:Float = 0, y:Float = 0, ?text:String = "", ?onClick:PlayerSlotIdentifier->Void, ?sprite:CustomButtonContent) {
      super(x, y, text);

      this.cursorOnUp = onClick;

      if (sprite == null) {
         this.loadDefaultGraphic();
      } else {
         if (!(sprite is NamespacedKey))
            sprite = NamespacedKey.ofDefaultNamespace(cast sprite);

         var asset = AssetHelper.getImageAsset(sprite);
         this.loadGraphic(asset, true, asset.width, Math.ceil(asset.height / 3), false, (cast sprite).toString());
         this.graphic.persist = true;
      }
   }

   function isOverlapping(p:PlayerSlot) {
      if (!p.visible)
         return false;
      var c = p.getCursorPosition();
      var point = FlxPoint.get(c.x, c.y);
      var overlaps = overlapsPoint(point);
      point.put();
      c.putWeak();
      return overlaps;
   }

   function checkCursorOverlap():Array<PlayerSlotIdentifier> {
      return [for (player in PlayerSlot.players) if (isOverlapping(player)) player.slot];
      /*var output:Array<PlayerSlotIdentifier> = [];
         if (overlappingCursors[0])
            output.push(P1);
         if (overlappingCursors[1])
            output.push(P2);
         if (overlappingCursors[2])
            output.push(P3);
         if (overlappingCursors[3])
            output.push(P4);
         if (overlappingCursors[4])
            output.push(P5);
         if (overlappingCursors[5])
            output.push(P6);
         if (overlappingCursors[6])
            output.push(P7);
         if (overlappingCursors[7])
            output.push(P8);
         return output; */
   }

   function updateState() {
      var isHovered:Bool = false;
      var isClicked:Bool = false;
      for (slot => state in this.getRealHovered().keyValueIterator())
         if (state) {
            isHovered = true;
            break;
         }

      if (isHovered)
         for (slot => state in this.getRealClicked().keyValueIterator())
            if (state) {
               isClicked = true;
               break;
            }

      if (isClicked) {
         this.status = FlxButton.PRESSED;
      } else if (isHovered) {
         this.status = FlxButton.HIGHLIGHT;
      } else {
         this.status = FlxButton.NORMAL;
      }
   }

   public function overHandler(slot:PlayerSlotIdentifier) {
      if (this.currentHoveredCursors.get(slot) == true)
         return;
      this.currentHoveredCursors.set(slot, true);
      this.updateState();
      if (this.cursorOnOver != null)
         this.cursorOnOver(slot);
   }

   public function upHandler(slot:PlayerSlotIdentifier) {
      if (this.currentClickedCursors.get(slot) == false)
         return;
      this.currentClickedCursors.set(slot, false);
      this.updateState();
      if (this.cursorOnUp != null)
         this.cursorOnUp(slot);
   }

   public function outHandler(slot:PlayerSlotIdentifier) {
      if (this.currentHoveredCursors.get(slot) == false)
         return;
      this.currentHoveredCursors.set(slot, false);
      this.currentClickedCursors.set(slot, false);
      this.updateState();
      if (this.cursorOnOut != null)
         this.cursorOnOut(slot);
   }

   public function downHandler(slot:PlayerSlotIdentifier) {
      if (this.currentClickedCursors.get(slot) == true)
         return;
      this.currentClickedCursors.set(slot, true);
      this.updateState();
      if (this.cursorOnDown != null)
         this.cursorOnDown(slot);
   }

   override function updateButton() {
      return; // i think i literally need to do nothing here lol
   }
}
