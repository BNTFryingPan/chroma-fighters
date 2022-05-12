package states.sub;

import GameManager.GameState;
import flixel.FlxSubState;

class PauseScreen extends FlxSubState {
   var resumeButton:CustomButton;
   var exitButton:CustomButton;

   override public function create() {
      super.create();

      this.bgColor = 0x77000000;

      this.resumeButton = new CustomButton(0, 0, "Resume", (slot) -> {
         GameManager.unpause(slot);
      });

      this.exitButton = new CustomButton(0, 0, "Title Screen", (slot) -> {
         if (GameManager.isMaster(slot))
            GameManager.returnToTitleScreen();
      });

      this.resumeButton.screenCenter(XY);
      this.resumeButton.y -= 15;
      this.exitButton.screenCenter(XY);
      this.exitButton.y += 15;

      add(this.resumeButton);
      add(this.exitButton);
   }
}
