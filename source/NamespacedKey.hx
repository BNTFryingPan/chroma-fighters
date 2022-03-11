package;

import flixel.util.typeLimit.OneOfTwo;
import openfl.errors.TypeError;

using StringTools;

@:forward
abstract class AbstractNamespacedKey {
   public var key:String;
   public var namespace:String;

   @:to
   public function toString() {
      return 'NamespacedKey{${this.namespace}:${this.key}}';
   }

   @:from
   public static function fromString(str:String) {
      var splitKey = str.split(":");
      if (splitKey.length == 1)
         return NamespacedKey.ofDefaultNamespace(str);

      var _namespace = splitKey[0];
      if (splitKey.length > 2) {
         splitKey.shift();
         return new NamespacedKey(_namespace, splitKey.join(":"));
      }
      return new NamespacedKey(_namespace, splitKey[1]);
   }

   @:op(A == B)
   public static function equals(A:AbstractNamespacedKey, B:AbstractNamespacedKey) {
      return (A.namespace == B.namespace) && (A.key == B.key);
   }
}

class NamespacedKey extends AbstractNamespacedKey {
   public static final DEFAULT_NAMESPACE = "chromafighters";
   public static final SPECIAL_NAMESPACES:Map<String, String> = [
      'cf_magic_fighter' => 'chromafighters:fighters/magic_fighter/{key}',
      'cf_stages' => 'chromafighters:stages/{key}',
      'cf_chroma_fracture_stage' => 'cf_stages:chroma_fracture/{key}'
   ];

   public function new(namespace:String, key:String) {
      trace('new namespaced key');
      if (namespace == null)
         namespace = NamespacedKey.DEFAULT_NAMESPACE;
      this.namespace = namespace;
      this.key = key;
   }

   public static function ofDefaultNamespace(obj:OneOfTwo<String, NamespacedKey>) {
      if (obj is NamespacedKey) {
         return oDN_key(cast obj);
      }
      return oDN_string(cast obj);
   }

   public function parseSpecialNamespaces():NamespacedKey {
      if (NamespacedKey.SPECIAL_NAMESPACES.exists(this.namespace)) {
         var newFormat = NamespacedKey.SPECIAL_NAMESPACES.get(this.namespace).split(':');
         this.namespace = newFormat[0];
         if (newFormat.length > 2) {
            newFormat.shift();
            newFormat = ['', newFormat.join(':')];
         }
         this.key = newFormat[1].replace('{key}', this.key);
         return this.parseSpecialNamespaces();
      }
      return this;
   }

   public function withKey(key:String):NamespacedKey {
      return new NamespacedKey(this.namespace, key);
   }

   private static function oDN_string(str:String) {
      return new NamespacedKey(NamespacedKey.DEFAULT_NAMESPACE, str);
   }

   private static function oDN_key(key:NamespacedKey) {
      return new NamespacedKey(NamespacedKey.DEFAULT_NAMESPACE, key.key);
   }

   public function asFileReference():String {
      return this.key.split("-").join("_").split(".").join("__");
   }
}
