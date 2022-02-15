package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import cpuController.CpuController;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.controllers.GenericController;
import inputManager.Position;

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
      return InputManager.getPlayerArray().filter(input -> {
         return Std.isOfType(input, GenericController);
      }).map(input -> {
         var c:GenericController = cast input;
         return c._flixelGamepad;
      });
   }

   public static function getPlayerSlotByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlotIdentifier> {
      if (Std.isOfType(input, InputType)) {
         var type:InputType = cast input;
         if (type == KeyboardInput || type == KeyboardAndMouseInput) {
            var matchingInputs = PlayerSlot.getPlayerArray().filter(thisInput -> {
               return Std.isOfType(thisInput, KeyboardHandler);
            });
            if (matchingInputs.length > 0) {
               return matchingInputs[0].slot;
            }
         }
         return null;
      }
      var gamepad:FlxGamepad = cast input;
      for (slot => input in PlayerSlot.players) {
         if (Std.isOfType(input, GenericController)) {
            var c:GenericController = cast input;
            if (c._flixelGamepad == gamepad) {
               return cast slot;
            }
         }
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

   public static function getCursors():Array<Position> {
      return PlayerSlot.getPlayerArray().map(function(p) {
         return p.getCursorPosition();
      });
   }

   public static function anyPlayerPressingAction(act:Action):Bool {
      for (p in getPlayerArray()) {
         switch (act) {
            case NULL:
               return false;
            case MENU_CONFIRM:
               if (InputHelper.isPressed(p.getConfirm()))
                  return true;
            case MENU_CANCEL:
               if (InputHelper.isPressed(p.getCancel()))
                  return true;
            case MENU_ACTION:
               if (InputHelper.isPressed(p.getMenuAction()))
                  return true;
            case MENU_LEFT:
               if (InputHelper.isPressed(p.getMenuLeft()))
                  return true;
            case MENU_RIGHT:
               if (InputHelper.isPressed(p.getMenuRight()))
                  return true;
            case MENU_BUTTON:
               if (InputHelper.isPressed(p.getMenuButton()))
                  return true;
            case JUMP:
               if (InputHelper.isPressed(p.getJump()))
                  return true;
            case SHORT_JUMP:
               if (InputHelper.isPressed(p.getJump()))
                  return true;
            case ATTACK:
               if (InputHelper.isPressed(p.getAttack()))
                  return true;
            case SPECIAL:
               if (InputHelper.isPressed(p.getSpecial()))
                  return true;
            case STRONG:
               if (InputHelper.isPressed(p.getStrong()))
                  return true;
            case TAUNT:
               if (InputHelper.isPressed(p.getTaunt()))
                  return true;
            case SHIELD:
               if (InputHelper.isPressed(p.getShield()))
                  return true;
            case WALK:
               if (InputHelper.isPressed(p.getWalk()))
                  return true;
            default:
               break;
         }
      }

      return false;
   }
}
