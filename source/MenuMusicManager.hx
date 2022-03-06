package;

import flixel.system.FlxSound;

enum MenuMusicState {
   TITLE;
   FIGHTER_SELECT;
   STAGE_SELECT;
   SUB_A;
   SUB_B;
}

class MenuMusicManager {
   private static var sound_intro:FlxSound;
   private static var sound_base:FlxSound;
   private static var sound_fighter:FlxSound;
   private static var sound_stage:FlxSound;
   private static var sound_sub_base:FlxSound;
   private static var sound_sub_a:FlxSound;
   private static var sound_sub_b:FlxSound;

   private static var _hasFinishedIntro:Bool = false;

   // layer modifiers
   public static var force_sub_base:Bool = false;
   public static var force_sub_a:Bool = false;
   public static var force_sub_b:Bool = false;
   public static var force_stage:Bool = false;
   public static var force_fighter:Bool = false;

   public static function load() {
      sound_base = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_base'), true);
      sound_intro = AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/music/menu_intro'), false);
      sound_intro.onComplete = MenuMusicManager.onIntroComplete;
      sound_intro.play();
   }

   public static function onIntroComplete() {
      sound_base.play();
   }
}
