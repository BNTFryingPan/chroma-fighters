package text;

enum TextTag {
   TEXT(text:String);
   COLOR(text:TextTag, color:String);
   ITALIC(text:TextTag);
}

class TextParser {
   private static inline final TAG_OPEN = '<';
   private static inline final TAG_CLOSE = '>';
   private static inline final CLOSE_TAG = '/';
   private static inline final SEPARATOR = ':';
   private static inline final ESCAPE = '\\';
}
