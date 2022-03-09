package match.fighter;

import AssetHelper;
import GameManager.GameState;
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
import inputManager.Action;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputState;
import match.fighter.AbstractFighter;
import match.hitbox.SquareHitbox;

using StringTools;

class MagicFighterMoves extends FighterMoves {
   public function new(fighter:MagicFighter) {
      super(fighter);
      this.moves.set('jab', new MagicFighterJab(fighter));
      this.moves.set('taunt', new MagicFighterTaunt(fighter));
      this.moves.set('nspecial', new MagicFighterNeutralSpecial(fighter));
      this.moves.set('uspecial', new MagicFighterUpwardSpecial(fighter));
      this.moves.set('dspecial', new MagicFighterDownwardSpecial(fighter));
      this.moves.set('fspecial', new MagicFighterForwardSpecial(fighter));
      this.moves.set('uair', new MagicFighterUpwardAirMove(fighter));
      this.moves.set('nair', new MagicFighterNeutralAirMove(fighter));
      this.moves.set('fair', new MagicFighterForwardAirMove(fighter));
      this.moves.set('dair', new MagicFighterDownwardAirMove(fighter));
      this.moves.set('bair', new MagicFighterBackwardAirMove(fighter));
      this.moves.set('ustrong', new MagicFighterUpwardStrong(fighter));
      this.moves.set('fstrong', new MagicFighterForwardStrong(fighter));
      this.moves.set('dstrong', new MagicFighterDownwardStrong(fighter));
      this.moves.set('utilt', new MagicFighterUpwardTilt(fighter));
      this.moves.set('ftilt', new MagicFighterForwardTilt(fighter));
      this.moves.set('dtilt', new MagicFighterDownwardTilt(fighter));
   }
}

class MagicFighterTaunt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state == JUST_PRESSED) {
         Main.debugDisplay.notify('magic taunt!');
         FlxTween.color((cast this.fighter).sprite, 1, FlxColor.PINK, FlxColor.WHITE);
      }

      if (InputHelper.isPressed(state)) {
         (cast this.fighter).forceAnim = 'taunt2';
         return SUCCESS(null);
      }
      return REJECTED(null);
   }
}

abstract class MagicFighterStrongMove extends FighterMove {
   private var _isCharging = true;
   private var chargeTime:Float;

   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      var elapsed:Float = params[0];
      if (state == JUST_PRESSED) {
         this._isCharging = true;
         this.fighter.moveFreeze(this.maxChargeTime());
         this.playChargeAnimation();
      } else if (state == JUST_RELEASED || elapsed >= this.maxChargeTime()) {
         this._isCharging = false;
         return this.releaseChargedAttack(input, this.chargeTime, ...params);
      }
      return SUCCESS(null);
   }

   abstract function maxChargeTime():Float;

   abstract function playChargeAnimation():Void;

   abstract function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult;
}

class MagicFighterForwardStrong extends MagicFighterStrongMove {
   function maxChargeTime():Float {
      return 1;
   }

   public function playChargeAnimation() {
      (cast this.fighter).forceAnim = 'forward_strong_charging';
   }

   public function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult {
      this.fighter.createRoundAttackHitbox(33, 40, 20, 15, true, 60, 0.2, 0.5);
      return SUCCESS(null);
   }
}

class MagicFighterUpwardStrong extends MagicFighterStrongMove {
   function maxChargeTime():Float {
      return 1;
   }

   public function playChargeAnimation() {
      (cast this.fighter).forceAnim = 'up_strong_charging';
   }

   public function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult {
      // this.fighter.createRoundAttackHitbox(33, 40, 20, 15, true, 60, 0.2, 0.5);
      return SUCCESS(null);
   }
}

class MagicFighterDownwardStrong extends MagicFighterStrongMove {
   function maxChargeTime():Float {
      return 1;
   }

   public function playChargeAnimation() {
      (cast this.fighter).forceAnim = 'down_strong_charging';
   }

   public function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult {
      // this.fighter.createRoundAttackHitbox(33, 40, 20, 15, true, 60, 0.2, 0.5);
      return SUCCESS(null);
   }
}

class MagicFighterNeutralSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'neutral_special';
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterUpwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'up_special';
      this.fighter.launch((Math.atan2(-input.getStick().y, -input.getStick().x) * FlxAngle.TO_DEG) - 90, 5, true);
      this.fighter.hitstunTime = 1;
      this.fighter.airState = PRATFALL;
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterForwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'forward_special';
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterDownwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'down_special';
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterJab extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'jab';
      this.fighter.createRoundAttackHitbox(30, 40, 15, 8, true, 65, 0.2, 0.5);
      return SUCCESS(null);
   }
}

class MagicFighterUpwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'up_tilt';
      return SUCCESS(null);
   }
}

class MagicFighterForwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'forward_tilt';
      return SUCCESS(null);
   }
}

class MagicFighterDownwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).forceAnim = 'down_tilt';
      return SUCCESS(null);
   }
}

class MagicFighterAerialMove extends FighterMove {
   public function attack():Void {}

   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      if (state != JUST_PRESSED)
         return REJECTED(null);
      this.attack();
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == GROUNDED)
         return REJECTED({success: false, reason: "NOT_IN_AIR"});
      if (this.fighter.airState == PRATFALL)
         return REJECTED({success: false, reason: 'IN_PRATFALL'});
      return SUCCESS(null);
   }
}

class MagicFighterNeutralAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).forceAnim = 'neutral_air';
   }
}

class MagicFighterUpwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).forceAnim = 'up_air';
   }
}

class MagicFighterForwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).forceAnim = 'forward_air';
   }
}

class MagicFighterBackwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).forceAnim = 'back_air';
   }
}

class MagicFighterDownwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).forceAnim = 'down_air';
      this.fighter.createRoundAttackHitbox(30, 40, 15, 8, true, 180, -1, 1);
   }
}

class MagicFighter extends AbstractFighter {
   private var jumpTime:Float = 0;
   private var maxJumpTime:Float = 0.3;
   private var isJumping:Bool = false;
   private var maxAirJumps:Int = 1;
   private var moveEndingLag:Float = 0;

   public var sprite:FlxSprite;

   public var canDodge(get, never):Bool;

   public function get_canDodge():Bool {
      if (this.airState == PRATFALL)
         return false;
      return true;
   }

   // var timedDodge:Timed = new Timed();
   var isDodging:Bool = false;
   var dodgeTimer:Float = -1;
   var dodgeDuration:Float = 1;
   var hasBufferedFastFall:Bool = false;

   /*public function setSpriteString(key:String, namespace:String = 'cf_magic_fighter') {
      var asset = AssetHelper.getImageAsset(new NamespacedKey(namespace, key));
      var frames = Math.floor(asset.width / asset.height);

      this.sprite.loadGraphic(asset, frames > 1, asset.height, asset.height);
      this.sprite.animation.
   }*/
   public function new(slot:PlayerSlotIdentifier, x:Float, y:Float) {
      super(slot, x, y);
      this.width = 40;
      this.height = 64;
      this.sprite = new FlxSprite();
      AssetHelper.generateCombinedSpriteSheetForFighter(new NamespacedKey('cf_magic_fighter', 'sprites'), this.sprite, 112, "idle");
      this.sprite.graphic.persist = true;

      // this.sprite.angularVelocity = 100;

      // this.sprite.centerOffsets();

      this.hitbox = new SquareHitbox(this.x, this.y, this.width, this.height);
   }

   override public function reloadTextures() {
      this.sprite.animation.destroyAnimations();
      AssetHelper.generateCombinedSpriteSheetForFighter(new NamespacedKey('cf_magic_fighter', 'sprites'), this.sprite, 112, this.sprite.animation.name);
      this.sprite.graphic.persist = true;
   }

   public var forceAnim:Null<String> = null;

   public function updateAnim(?prev:String) {
      if (prev == null)
         prev = this.sprite.animation.name;
      var fin = this.sprite.animation.finished;

      if (this.moveFreezeTime > 0 && fin && this.forceAnim != null)
         return;

      if (this.forceAnim != null) {
         if (!fin) {
            return this.play(this.forceAnim);
         }
         this.forceAnim = null;
      }

      if (prev.endsWith('_air') && this.airState != GROUNDED) {
         return this.play('idle_air');
      }

      if (this.airState == GROUNDED) {
         if (prev == 'dash') {} else if (Math.abs(this.velocity.x) > 10) {
            return this.play('walk');
         } else if (this.isCrouching) {
            if (prev == 'crouch_start' || prev == 'crouch_idle') {
               return this.play('crouch_idle');
            }
            return this.play('crouch_start');
         } else if (prev == 'crouch_idle') {
            return this.play('crouch_end');
         }
      }

      if (this.airState != GROUNDED) {
         if (this.velocity.y < 0 && (!fin || prev == 'idle')) {
            return this.play('jumping');
         } else {
            return this.play('idle_air');
         }
      }

      this.play('idle');
   };

   public function play(name:String, force:Bool = false) {
      //if (this.sprite.animation.get(name) == null)
         //return; // missing animation!
      return this.sprite.animation.play(name);
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
      super.handleInput(elapsed, input);
      var stick = input.getStick();
      this.updateAnim();

      if (this.slot == P2) {
         this.sprite.alpha = 0.5;
      }

      if (this.hitstunTime > 0)
         return;

      /*this.lastPressedDodge += elapsed;

         if (input.getDodge()) {
            this.lastPressedDodge = 0;
      }*/

      if (stick.length > 0) {
         var horizontalGroundModifier = this.airState == GROUNDED ? 1 : 0.4;
         if ((stick.x > 0 && this.velocity.x < (-200 * Math.abs(stick.x)))
            || (stick.x < 0 && this.velocity.x > (200 * Math.abs(stick.x)))) {
            this.velocity.x += stick.x * 4000 * elapsed;
            if (this.sprite.animation.name == 'idle') {
               this.play('dash');
            }
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
         // this.airState = FULL_CONTROL;
      }

      this.isCrouching = false;
      if (stick.y >= 0.3) {
         if (!this.hasBufferedFastFall && this.velocity.y >= -50 && this.velocity.y <= 250 && !(this.airState == GROUNDED)) {
            this.hasBufferedFastFall = true;
         } else if (this.airState == GROUNDED) {
            this.isCrouching = true;
         }
      }

      if (this.velocity.y > 0 && this.hasBufferedFastFall) {
         this.velocity.y = 350;
         this.hasBufferedFastFall = false;
      }

      function attemptMove(name, action:Action, ...params:Any) {
         this.moveset.attempt(name, input.getAction(action), input, ...params);
      }

      // Main.debugDisplay.notify('${this.airJumps}/${this.maxAirJumps} ${this.isJumping} ${FlxMath.roundDecimal(this.velocity.y, 1)} ${FlxMath.roundDecimal(this.acceleration.y, 1)}');
      // todo : fastfall
      if (this.airState != PRATFALL) {
         attemptMove('taunt', TAUNT);

         switch (this.getAttackDirection(stick)) {
            case UP:
               attemptMove('utilt', ATTACK);
               attemptMove('uspecial', SPECIAL);
               attemptMove('uair', ATTACK);
               attemptMove('ustrong', STRONG, elapsed);
            case DOWN:
               attemptMove('dtilt', ATTACK);
               attemptMove('dspecial', SPECIAL);
               attemptMove('dair', ATTACK);
               attemptMove('dstrong', STRONG, elapsed);
            case LEFT:
               attemptMove('ftilt', ATTACK, this.facing);
               attemptMove('fstrong', STRONG, this.facing, elapsed);
               attemptMove('fspecial', SPECIAL, this.facing);
               if (this.facing == LEFT)
                  attemptMove('fair', ATTACK, this.facing);
               else
                  attemptMove('bair', ATTACK, this.facing);
            case RIGHT:
               attemptMove('ftilt', ATTACK, this.facing);
               attemptMove('fstrong', STRONG, this.facing, elapsed);
               attemptMove('fspecial', SPECIAL, this.facing);
               if (this.facing == LEFT)
                  attemptMove('bair', ATTACK, this.facing);
               else
                  attemptMove('fair', ATTACK, this.facing);
            case NEUTRAL:
               attemptMove('jab', ATTACK, input);
               attemptMove('nair', ATTACK, input);
               attemptMove('nspecial', SPECIAL, input);
         }
      }

      if (this.airState == GROUNDED) {
         if (this.velocity.x > 0)
            this.facing = LEFT;
         if (this.velocity.x < 0)
            this.facing = RIGHT;
      }
   }

   public var isCrouching:Bool = false;

   override public function update(elapsed:Float) {
      super.update(elapsed);
      #if debug
      if (!GameState.animationDebugMode || GameState.animationDebugTick) {
         if (GameState.animationDebugTick)
            this.sprite.animation.curAnim.curFrame += this.sprite.animation.curAnim.reversed ? -1 : 1;
      #end
         this.sprite.animation.update(elapsed);
      #if debug
      }
      #end
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
         '${this.airJumps} / ${this.maxAirJumps} [${this.hasBufferedFastFall ? 'F' : 'f'}] a=${this.sprite.animation.name}.${this.sprite.animation.curAnim.curFrame}/${this.sprite.animation.curAnim.numFrames} ${this.sprite.animation.frameIndex} ${FlxMath.roundDecimal(this.hitstunTime, 2)} ${FlxMath.roundDecimal(this.iframes, 2)} ${this.facing}\n${this.airState} ${FlxMath.roundDecimal(this.aliveTime, 2)} ${this.airState == RESPAWN && this.aliveTime >= 3} ${FlxMath.roundDecimal(this.airStateTime, 2)}';
   }
}
