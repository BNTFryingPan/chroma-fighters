package match.fighter;

import AssetHelper;
import GameManager.ScreenSprite;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputState;
import match.fighter.AbstractFighter;

class MagicFighterMoves extends FighterMoves {
   // private final taunt:MagicFighterTaunt;
   public function new(fighter:MagicFighter) {
      super(fighter);
      this.moves.set('taunt', new MagicFighterTaunt(fighter));
      this.moves.set('special', new MagicFighterSpecial(fighter));
      this.moves.set('dair', new MagicFighterAerialMove(fighter));
      this.moves.set('jab', new MagicFighterJab(fighter));
   }
}

class MagicFighterTaunt extends FighterMove {
   public function attempt(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state == JUST_PRESSED) {
         Main.debugDisplay.notify('magic taunt!');
         FlxTween.color((cast this.fighter).sprite, 1, FlxColor.PINK, FlxColor.WHITE);
      }

      if (InputHelper.isPressed(state))
         return SUCCESS(null);
      return REJECTED(null);
   }
}

class MagicFighterSpecial extends FighterMove {
   public function attempt(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state == JUST_PRESSED) {
         this.fighter.launch(Math.atan2(-input.getStick().y, input.getStick().x) * FlxAngle.TO_DEG, 10, true);
         this.fighter.airState = PRATFALL;
         return SUCCESS(null);
      }
      return REJECTED(null);
   }
}

class MagicFighterJab extends FighterMove {
   public function attempt(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state == JUST_PRESSED) {
         this.fighter.createRoundAttackHitbox({x: 25, y: 40}, 15, 10, 45, 0.5, 1);
         return SUCCESS(null);
      }
      return REJECTED(null);
   }
}

class MagicFighterAerialMove extends FighterMove {
   public function attempt(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state != JUST_PRESSED)
         return REJECTED(null);
      if (this.fighter.airState == GROUNDED)
         return REJECTED({success: false, reason: "NOT_IN_AIR"}); // this.fighter.createRoundAttackHitbox()
      this.fighter.createRoundAttackHitbox({x: 30, y: 40}, 15, 10, 80, 0.2, 1);
      return SUCCESS(null);
   }
}

class MagicFighter extends AbstractFighter {
   private var jumpTime:Float = 0;
   private var maxJumpTime:Float = 0.3;
   private var isJumping:Bool = false;
   private var maxAirJumps:Int = 1;
   private var moveEndingLag:Float = 0;

   public var sprite:FlxSprite;

   var dodgeTimer:Float = -1;
   var dodgeDuration:Float = 1;
   var hasBufferedFastFall:Bool = false;

   public function setSpriteString(key:String) {
      this.sprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace(key)));
   }

   public function new(slot:PlayerSlotIdentifier, x:Float, y:Float) {
      super(slot, x, y);
      this.width = 40;
      this.height = 64;
      this.sprite = new FlxSprite();
      this.setSpriteString('images/martha_idle');
      this.sprite.angularVelocity = 100;

      // this.sprite.centerOffsets();

      this.hitbox = new SquareHitbox(this.x, this.y, this.width, this.height);
   }

   override public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   private var lastStickDownValue:String = '0';

   private function clamp(value:Float, ?min:Float, ?max:Float):Float {
      if (min != null && min >= value)
         return min;
      if (max != null && max <= value)
         return max;
      return value;
   }

   override public function handleInput(elapsed:Float, input:GenericInput) {
      var stick = input.getStick();
      // this.lastStickDownValue = '${stick.y} ${input.getDown()}';
      // this.lastStickDownValue = input.getDown();
      // trace(elapsed);

      // ScreenSprite.circle({x: this.x, y: this.y}, 50, {thickness: 3, color: 0xFFFF00FF});

      if (this.hitstunTime > 0)
         return;

      // if (input.getDodge())

      if (stick.length > 0) {
         var horizontalGroundModifier = this.airState == GROUNDED ? 1 : 0.4;
         if ((stick.x > 0 && this.velocity.x < (-200 * Math.abs(stick.x)))
            || (stick.x < 0 && this.velocity.x > (200 * Math.abs(stick.x)))) {
            this.velocity.x += stick.x * 4000 * elapsed;
         } else if (Math.abs(this.velocity.x) > (200 * Math.abs(stick.x))) {
            // max velocity. might do something later idk
         } else {
            this.velocity.x += stick.x * 4000 * elapsed * horizontalGroundModifier;
         }
      }

      var jumpState = InputHelper.realJumpState(input);
      var jumpPressed = InputHelper.isPressed(jumpState);

      if (this.isJumping && !jumpPressed) {
         this.isJumping = false;
      }

      if (!this.isJumping && (this.airState == GROUNDED || this.airJumps > 0)) {
         this.jumpTime = 0;
         if (this.airState == GROUNDED) {
            this.airJumps = this.maxAirJumps;
            this.hasBufferedFastFall = false;
         }
      }

      if (this.jumpTime >= 0 && jumpPressed) {
         this.isJumping = true;
         this.jumpTime += elapsed;
         if (jumpState == JUST_PRESSED && this.airState != GROUNDED)
            this.airJumps--;
      } else {
         this.jumpTime = -1;
      }

      if (jumpTime > 0 && jumpTime < maxJumpTime) {
         this.velocity.y = -200;
         this.airState = FULL_CONTROL;
      }

      if (stick.y >= 0.3) {
         if (!this.hasBufferedFastFall && this.velocity.y >= -50 && this.velocity.y <= 250) {
            this.hasBufferedFastFall = true;
         } else if (this.airState == GROUNDED) {
            // crouch
         }
      }

      if (this.velocity.y > 0 && this.hasBufferedFastFall) {
         this.velocity.y = 350;
         this.hasBufferedFastFall = false;
      }

      // Main.debugDisplay.notify('${this.airJumps}/${this.maxAirJumps} ${this.isJumping} ${FlxMath.roundDecimal(this.velocity.y, 1)} ${FlxMath.roundDecimal(this.acceleration.y, 1)}');
      // todo : fastfall
      if (this.airState != PRATFALL) {
         if (this.airState == GROUNDED)
            this.moveset.attempt('taunt', input.getTaunt(), input);
         this.moveset.attempt('special', input.getSpecial(), input);
         if (this.airState != GROUNDED)
            this.moveset.attempt('dair', input.getAttack(), input);
         if (this.airState == GROUNDED)
            this.moveset.attempt('jab', input.getAttack(), input);
      }

      if (this.airState == GROUNDED) {
         if (this.velocity.x > 0)
            this.facing = LEFT;
         if (this.velocity.x < 0)
            this.facing = RIGHT;
      }
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      this.sprite.setPosition(this.x - 20, this.y - 7);
      this.sprite.flipX = this.facing == RIGHT;
   }

   override public function draw() {
      super.draw();
      this.sprite.draw();
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }

   override public function getDebugString():String {
      return
         '${this.airJumps} / ${this.maxAirJumps} [${this.hasBufferedFastFall ? 'F' : 'f'}] ${FlxMath.roundDecimal(this.hitstunTime, 2)} ${FlxMath.roundDecimal(this.iframes, 2)} ${this.facing}';
   }
}
