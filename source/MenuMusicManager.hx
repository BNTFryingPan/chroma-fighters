package;

import GameManager.GameState;
import flixel.system.FlxSound;
import openfl.display.GraphicsQuadPath;

enum MenuMusicState {
   INTRO;
   TITLE;
   FIGHTER_SELECT;
   STAGE_SELECT;
   SUB_PURE;
   SUB_A;
   SUB_B;
   WACKY;
}

enum MenuMusicLayer {
   INTRO;
   BASE;
   SUB_FIGHTER;
   SUB_STAGE;
   SUB_BASE;
   SUB_EXTRA_A;
   SUB_EXTRA_B;
}

class MenuMusicManager {
   private static var sound_intro:FlxSound;
   private static var sound_base:FlxSound;
   private static var sound_sub_fighter:FlxSound;
   private static var sound_sub_stage:FlxSound;
   private static var sound_sub_base:FlxSound;
   private static var sound_sub_extra_a:FlxSound;
   private static var sound_sub_extra_b:FlxSound;

   private static var _hasFinishedIntro:Bool = false;

   public static var musicState(default, set):MenuMusicState = INTRO;

   public static final musicLayersPerState:Map<MenuMusicState, Array<MenuMusicLayer>> = [
      INTRO => [INTRO],
      TITLE => [BASE],
      FIGHTER_SELECT => [BASE, SUB_FIGHTER],
      STAGE_SELECT => [BASE, SUB_FIGHTER, SUB_STAGE],
      SUB_PURE => [BASE, SUB_BASE],
      SUB_A => [BASE, SUB_BASE, SUB_EXTRA_A],
      SUB_B => [BASE, SUB_BASE, SUB_EXTRA_B],
      WACKY => [SUB_STAGE, SUB_EXTRA_B],
   ];

   public static final allMusicLayers:Array<MenuMusicLayer> = [BASE, SUB_FIGHTER, SUB_STAGE, SUB_BASE, SUB_EXTRA_A, SUB_EXTRA_B];

   // layer modifiers
   public static var force_sub_base:Bool = false;
   public static var force_sub_a:Bool = false;
   public static var force_sub_b:Bool = false;
   public static var force_stage:Bool = false;
   public static var force_fighter:Bool = false;

   public static function load() {
      sound_intro = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_intro'), false, true);
      sound_base = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_base'), true, true);
      sound_sub_fighter = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_sub_fighter'), true, true);
      sound_sub_stage = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_sub_stage'), true, true);
      sound_sub_base = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_sub_base'), true, true);
      sound_sub_extra_a = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_sub_extra_a'), true, true);
      sound_sub_extra_b = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_sub_extra_b'), true, true);
      sound_sub_fighter.volume = 0;
      sound_sub_stage.volume = 0;
      sound_sub_base.volume = 0;
      sound_sub_extra_a.volume = 0;
      sound_sub_extra_b.volume = 0;
      sound_intro.onComplete = MenuMusicManager.onIntroComplete;
      sound_base.onComplete = () -> {
         Main.debugDisplay.notify('music loop');
      }
      sound_intro.play();
   }

   public static function pause():Void {
      sound_base.pause();
      sound_sub_fighter.pause();
      sound_sub_stage.pause();
      sound_sub_base.pause();
      sound_sub_extra_a.pause();
      sound_sub_extra_b.pause();
   }

   public static function resume():Void {
      sound_base.play();
      sound_sub_fighter.play();
      sound_sub_stage.play();
      sound_sub_base.play();
      sound_sub_extra_a.play();
      sound_sub_extra_b.play();
   }

   public static function debugText():String {
      if (GameState.isInMatch)
         return '';

      var ret = 'MenuMusicManager state: ${musicState} ${_hasFinishedIntro}\n';
      ret += 'base: ${sound_base.time}/${sound_base.length} ${sound_base.volume}\n';
      ret += 'figh: ${sound_sub_fighter.time}/${sound_sub_fighter.length} ${sound_sub_fighter.volume}\n';
      ret += 'stag: ${sound_sub_stage.time}/${sound_sub_stage.length} ${sound_sub_stage.volume}\n';
      ret += 'sub_: ${sound_sub_base.time}/${sound_sub_base.length} ${sound_sub_base.volume}\n';
      ret += 'suba: ${sound_sub_extra_a.time}/${sound_sub_extra_a.length} ${sound_sub_extra_a.volume}\n';
      ret += 'subb: ${sound_sub_extra_b.time}/${sound_sub_extra_b.length} ${sound_sub_extra_b.volume}\n';
      return ret;
   }

   public static function getSoundLayer(layer:MenuMusicLayer):FlxSound {
      return switch (layer) {
         case INTRO:
            sound_intro;
         case BASE:
            sound_base;
         case SUB_FIGHTER:
            sound_sub_fighter;
         case SUB_STAGE:
            sound_sub_stage;
         case SUB_BASE:
            sound_sub_base;
         case SUB_EXTRA_A:
            sound_sub_extra_a;
         case SUB_EXTRA_B:
            sound_sub_extra_b;
      }
   }

   public static function onIntroComplete() {
      _hasFinishedIntro = true;
      sound_base.play();
      sound_sub_fighter.play();
      sound_sub_stage.play();
      sound_sub_base.play();
      sound_sub_extra_a.play();
      sound_sub_extra_b.play();
      musicState = musicState == INTRO ? TITLE : musicState;
   }

   /*public static function titleState():MenuMusicState {
      sound_sub_fighter.fadeOut(0.5);
      sound_sub_stage.fadeOut(0.5);
      sound_sub_base.fadeOut(0.5);
      sound_sub_extra_a.fadeOut(0.5);
      sound_sub_extra_b.fadeOut(0.5);
      return TITLE;
   }*/
   // public static function fighterState():MenuMusicState {}

   static function set_musicState(value:MenuMusicState):MenuMusicState {
      if (!_hasFinishedIntro)
         return musicState = value;

      var layersInThisState = musicLayersPerState.get(value);
      for (layer in allMusicLayers) {
         var sound = getSoundLayer(layer);
         if (sound.volume > 0 && !layersInThisState.contains(layer))
            sound.fadeOut(0.5);
         else if (sound.volume <= 0 && layersInThisState.contains(layer))
            sound.fadeIn(0.5);
      }
      return musicState = value;
   }
}
