package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;

interface ChromaFightersState {
   public function stateId():String;
}

/**
   a base for other states in the game

   contains core functionality that allows the input manager to work
**/
class BaseState extends FlxState implements ChromaFightersState {
   override public function create() {
      super.create();

      FlxG.autoPause = false;
      this.persistentUpdate = true;

      // add(new MonospaceText(100, 200, 0, "HI"));

      /*if (FlxG.gamepads.lastActive != null) { // if there is a controller connected, make the last active (arbitrary?) controller the P1 input
             InputManager.setInputType(P1, ControllerInput);
             InputManager.setInputDevice(P1, FlxG.gamepads.lastActive);
         } else { // otherwise default to keyboard input
             InputManager.setInputType(P1, KeyboardInput);
      }*/
   }

   @:access(flixel.FlxCamera)
   override public function draw() {
      if (this.persistentDraw || this.subState == null) {
         var i:Int = 0;
         var basic:FlxBasic = null;

         var oldDefaultCameras = FlxCamera._defaultCameras;
         if (this.cameras != null) {
            FlxCamera._defaultCameras = this.cameras;
         }

         while (i < this.length) {
            basic = this.members[i++];

            if (basic != null && basic.exists && basic.visible) {
               basic.draw();
            }
         }

         FlxCamera._defaultCameras = oldDefaultCameras;
      }

      GameManager.draw_preSubState();

      if (this.subState != null)
         this.subState.draw();

      GameManager.draw();
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      GameManager.update(elapsed);
   }

   // used for the debug screen lmao
   public function stateId():String {
      return 'Unknown (base state)';
   }
}
