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
import haxe.Constraints.Function;
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
         (cast this.fighter).play('taunt2', true, true);
         return SUCCESS(null);
      }
      return REJECTED(null);
   }

   public function getAction() {
      return Action.TAUNT;
   }
}

abstract class MagicFighterStrongMove extends FighterMove {
   private var _isCharging = true;
   private var chargeTime:Float;

   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      var elapsed:Float = params[1];
      if (state == JUST_PRESSED) {
         this._isCharging = true;
         this.fighter.moveFreeze(this.maxChargeTime());
         this.playChargeAnimation();
         trace('charge start');
         return SUCCESS(null);
      } else if (state == JUST_RELEASED || elapsed >= this.maxChargeTime()) {
         this._isCharging = false;
         this.releaseChargedAttack(input, this.chargeTime, ...params);
         trace('charge release');
         return REJECTED({success: true, reason: 'CHARGE_ATTACK_RELEASED'});
      } else if (state == PRESSED && this._isCharging) {
         this.chargeTime += elapsed;
         trace('charge progressed');
         return SUCCESS(null);
      }
      trace('not pressed?');
      return REJECTED(null);
   }

   public function getAction() {
      return Action.STRONG;
   }

   override public function shouldPerform(state:InputState, input:GenericInput):String {
      return '';
   }

   abstract function maxChargeTime():Float;

   abstract function playChargeAnimation():Void;

   abstract function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult;
}

class MagicFighterForwardStrong extends MagicFighterStrongMove {
   public function maxChargeTime():Float {
      return 1;
   }

   public function playChargeAnimation() {
      (cast this.fighter).play('forward_strong_charging', true, true);
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
      (cast this.fighter).play('up_strong_charging', true, true);
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
      (cast this.fighter).play('down_strong_charging', true, true);
   }

   public function releaseChargedAttack(input:GenericInput, chargeTime:Float, ...params:Any):MoveResult {
      // this.fighter.createRoundAttackHitbox(33, 40, 20, 15, true, 60, 0.2, 0.5);
      return SUCCESS(null);
   }
}

class MagicFighterNeutralSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('neutral_special', true, true);
      return SUCCESS(null);
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.SPECIAL;
   }
}

class MagicFighterUpwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('up_special', true, true);
      this.fighter.launch((Math.atan2(-input.getStick().y, -input.getStick().x) * FlxAngle.TO_DEG) - 90, 5, true);
      this.fighter.hitstunTime = 1;
      this.fighter.airState = PRATFALL;
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.SPECIAL;
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterForwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('forward_special', true, true);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.SPECIAL;
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterDownwardSpecial extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('down_special', true, true);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.SPECIAL;
   }

   override public function canPerform() {
      if (this.fighter.airState == PRATFALL)
         return REJECTED(null);
      return SUCCESS(null);
   }
}

class MagicFighterJab extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('jab', true, true);
      this.fighter.createRoundAttackHitbox(30, 40, 15, 8, true, 65, 0.2, 0.5);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.ATTACK;
   }
}

class MagicFighterUpwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('up_tilt', true, true);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.ATTACK;
   }
}

class MagicFighterForwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('forward_tilt', true, true);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.ATTACK;
   }
}

class MagicFighterDownwardTilt extends FighterMove {
   public function perform(state:InputState, input:GenericInput, ...params:Any):MoveResult {
      (cast this.fighter).play('down_tilt', true, true);
      return SUCCESS(null);
   }

   public function getAction() {
      return Action.ATTACK;
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

   public function getAction() {
      return Action.ATTACK;
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
      (cast this.fighter).play('neutral_air', true, true);
   }
}

class MagicFighterUpwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).play('upward_air', true, true);
   }
}

class MagicFighterForwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).play('forward_air', true, true);
   }
}

class MagicFighterBackwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).play('back_air', true, true);
   }
}

class MagicFighterDownwardAirMove extends MagicFighterAerialMove {
   override public function attack() {
      (cast this.fighter).play('down_air', true, true);
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

   var animFPS = 12;

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

   public function play(name:String, force:Bool = false, applyEndLag:Bool = false) {
      // if (this.sprite.animation.get(name) == null)
      // return; // missing animation!
      if (this.sprite.animation.exists(name)) {
         if (force) {
            this.forceAnim = name;
         }
         if (applyEndLag) {
            this.moveFreezeTime = this.sprite.animation.getByName(name).frames.length * (this.animFPS / Main.targetFps); // * (1 / Main.targetFps);
            // this.moveFreeze(this.moveEndinmogLag);
            trace('endlag: ${this.sprite.animation.getByName(name).frames.length} frames * ${this.animFPS} fps = ${this.moveFreezeTime} end lag frames');
         }
         return this.sprite.animation.play(name, force);
      }
      trace('no such animation: ' + name);
   }

   override public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   private var lastStickDownValue:String = '0';

   public override function getScriptFunctions():Map<String, Function> {
      var map = super.getScriptFunctions();

      map.set("play", this.play);

      return map;
   }

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

      if (this.moveFreezeTime > 0)
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

      function attemptMove(name, ...params:Any) {
         this.moveset.attempt(name, input, ...params);
      }

      // Main.debugDisplay.notify('${this.airJumps}/${this.maxAirJumps} ${this.isJumping} ${FlxMath.roundDecimal(this.velocity.y, 1)} ${FlxMath.roundDecimal(this.acceleration.y, 1)}');
      // todo : fastfall
      if (this.airState != PRATFALL && this.moveFreezeTime == 0) {
         attemptMove('taunt');

         switch (this.getAttackDirection(stick)) {
            case UP:
               attemptMove('uspecial');
               if (this.airState == GROUNDED) {
                  attemptMove('ustrong', elapsed);
                  attemptMove('utilt');
               } else {
                  attemptMove('uair');
               }
            case DOWN:
               attemptMove('dspecial');
               if (this.airState == GROUNDED) {
                  attemptMove('dtilt');
                  attemptMove('dstrong', elapsed);
               } else {
                  attemptMove('dair');
               }
            case LEFT:
               attemptMove('fspecial', this.facing);
               if (this.airState == GROUNDED) {
                  attemptMove('ftilt', this.facing);
                  attemptMove('fstrong', this.facing, elapsed);
               } else {
                  if (this.facing == LEFT) {
                     attemptMove('fair', this.facing);
                  } else {
                     attemptMove('bair', this.facing);
                  }
               }
            case RIGHT:
               attemptMove('fspecial', this.facing);
               if (this.airState == GROUNDED) {
                  attemptMove('ftilt', this.facing);
                  attemptMove('fstrong', this.facing, elapsed);
               } else {
                  if (this.facing == LEFT) {
                     attemptMove('bair', this.facing);
                  } else {
                     attemptMove('fair', this.facing);
                  }
               }
            case NEUTRAL:
               attemptMove('nspecial');
               if (this.airState == GROUNDED) {
                  attemptMove('jab');
               } else {
                  attemptMove('nair');
               }
         }
      }

      if (this.moveFreezeTime > 0 && this.moveset.currentlyPerforming != null) {
         this.moveset.update(elapsed, input);
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
      this.sprite.setPosition(this.x - 36, this.y - 23);
      this.sprite.flipX = this.facing == RIGHT;
      // this.moveEndingLag = Math.max(0, this.moveEndingLag - elapsed);
      // this.moveEndingLag = Math.max(0, this.moveEndingLag - 1);
   }

   override public function draw() {
      super.draw();
      this.sprite.draw();
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }

   override public function getDebugString():String {
      if (this.sprite.animation.getNameList().length > 0)
         return '${this.airJumps} / ${this.maxAirJumps}' // jumps
            + '[${this.hasBufferedFastFall ? 'F' : 'f'}] ' // buffers
            + 'a=${this.sprite.animation.name}.' // animation details
            + '${this.sprite.animation.curAnim == null ? '' : '${this.sprite.animation.curAnim.curFrame} ${this.sprite.animation.curAnim.numFrames} '}'
            + '${this.sprite.animation.frameIndex} ${FlxMath.roundDecimal(this.hitstunTime, 2)}'
            + '${FlxMath.roundDecimal(this.iframes, 2)} ${this.facing}'
            + '\n${this.airState} ${FlxMath.roundDecimal(this.aliveTime, 2)}'
            + '${this.airState == RESPAWN && this.aliveTime >= 3}'
            + '${FlxMath.roundDecimal(this.airStateTime, 2)}\n' // air state time
            + '[${FlxMath.roundDecimal(this.moveEndingLag, 2)}:${FlxMath.roundDecimal(this.moveFreezeTime, 2)}]'; // end lag

      return '';
   }

   override private function airStateChange(newState, oldState) {
      if (this.moveFreezeTime > 0
         && newState == GROUNDED
         && this.forceAnim != null
         && this.forceAnim.endsWith('_air')
         && this.sprite.animation.exists('${this.forceAnim}_land')) {
         this.play('${this.forceAnim}_land', true, true);
      }
      // a
   }
}
