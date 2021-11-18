package;


import lime.system.CFFI;
import lime.system.JNI;


class Android {
	
	
	public static function sampleMethod (inputValue:Int):Int {
		
		#if android
		
		var resultJNI = android_sample_method_jni(inputValue);
		var resultNative = android_sample_method(inputValue);
		
		if (resultJNI != resultNative) {
			
			throw "Fuzzy math!";
			
		}
		
		return resultNative;
		
		#else
		
		return android_sample_method(inputValue);
		
		#end
		
	}
	
	
	private static var android_sample_method = CFFI.load ("android", "android_sample_method", 1);
	
	#if android
	private static var android_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.Android", "sampleMethod", "(I)I");
	#end
	
	
}