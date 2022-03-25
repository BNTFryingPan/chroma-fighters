package;

enum Platform {
   WINDOWS;
   DARWIN;
   LINUX;
   UNKNOWN_DESKTOP;
   ANDROID;
   IOS;
   UNKNOWN_MOBILE;
   WEB;
   UNKNOWN_JS;
}

class Version {
   public static final platform = new PlatformVar();
   public static final debug = #if debug true #else false #end;
   public static final sys = #if sys true #else false #end;
   public static final wackyassets = #if wackyassets true #else false #end;
   public static final modding_support = Version.sys && !Version.wackyassets;
   //public static final 
}

private class PlatformVar {
   public final type:Platform;

   public function new() {
      #if html5
      this.type = WEB;
      #elseif js
      this.type = UNKNOWN_JS;
      #elseif ios
      this.type = IOS;
      #elseif android
      this.type = ANDROID;
      #elseif mobile
      this.type = UNKNOWN_MOBILE;
      #elseif windows
      this.type = WINDOWS;
      #elseif mac
      this.type = DARWIN;
      #elseif linux
      this.type = LINUX;
      #else
      this.type = UNKNOWN_DESKTOP;
      #end
   }

   public function isMobile():Bool {
      if (this.type == IOS) return true;
      if (this.type == ANDROID) return true;
      return false;
   }
}
