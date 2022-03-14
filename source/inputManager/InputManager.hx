package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.InputDevice;
import inputManager.controllers.GenericController;

class InputManager {
   /*private static var players:Map<PlayerSlotIdentifier, GenericInput> = [
          P1 => new GenericInput(P1),
          P2 => new GenericInput(P2),
          P3 => new GenericInput(P3),
          P4 => new GenericInput(P4),
          P5 => new GenericInput(P5),
          P6 => new GenericInput(P6),
          P7 => new GenericInput(P7),
          P8 => new GenericInput(P8),
      ]; */
   public static function getPlayerArray():Array<GenericInput> {
      return PlayerSlot.getPlayerInputArray();
   }

   public static var enabled = false;

   public static function getPlayer(slot:PlayerSlotIdentifier) {
      return PlayerSlot.getPlayer(slot).input;
   }

   /*public static function setInputType(slot:PlayerSlotIdentifier, type:InputType, ?profile:String) {
      PlayerSlot.getPlayer(slot).setNewInput(type, null, profile);
      if (type == KeyboardInput) {
          players[slot].destroy();
          players[slot] = new KeyboardHandler(slot, profile);
      } else if (type == KeyboardAndMouseInput) {
          players[slot].destroy();
          players[slot] = new MouseHandler(slot, profile);
      } else if (type == ControllerInput) {
          players[slot].destroy();
          players[slot] = new GenericController(slot, profile);
      } else if (type == NoInput) {
          players[slot].destroy();
          players[slot] = new GenericInput(slot, profile);
      } else if (type == CPUInput) {
          players[slot].destroy();
          players[slot] = new CpuController(slot);
      }
   }*/
   public static function getUsedGamepads():Array<FlxGamepad> {
      return [
         for (player in PlayerSlot.players)
            if (Std.isOfType(player.input, GenericController)) (cast player.input)._flixelGamepad
      ];
      /*return InputManager.getPlayerArray().filter(input -> {
            return Std.isOfType(input, GenericController);
         }).map(input -> {
            var c:GenericController = cast input;
            return c._flixelGamepad;
      });*/
   }

   public static function getPlayerSlotByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlotIdentifier> {
      if (Std.isOfType(input, InputType)) {
         var type:InputType = cast input;
         if (type == KeyboardInput || type == KeyboardAndMouseInput)
            for (player in PlayerSlot.players)
               if (Std.isOfType(player.input, KeyboardHandler))
                  return player.slot;
         return null;
      }
      var gamepad:FlxGamepad = cast input;
      for (player in PlayerSlot.players)
         if (Std.isOfType(player.input, GenericController)) {
            var c:GenericController = cast player.input;
            if (c._flixelGamepad == gamepad)
               return player.slot;
         }

      return null;
   }

   public static function setInputDevice(slot:PlayerSlotIdentifier, inputDevice:OneOfTwo<FlxGamepad, InputDevice>) {
      if (inputDevice == Keyboard) // TODO : probably handle this better
         return;

      if (!Std.isOfType(PlayerSlot.getPlayer(slot).input, GenericController))
         return;

      var input:FlxGamepad = cast inputDevice;
      var player:GenericController = cast getPlayer(slot);
      player._flixelGamepad = input;
   }

   public static function getCursors():Array<Coordinates> {
      return [for (player in PlayerSlot.players) player.getCursorPosition()];
   }

   public static function playersPressingAction(act:Action):Array<PlayerSlot> {
      return [
         for (player in PlayerSlot.players)
            if (InputHelper.isPressed(player.input.getAction(act))) player
      ];
   }

   public static function anyPlayerPressingAction(act:Action):Bool {
      for (p in getPlayerArray())
         if (InputHelper.isPressed(p.getAction(act)))
            return true;

      return false;
   }
}
