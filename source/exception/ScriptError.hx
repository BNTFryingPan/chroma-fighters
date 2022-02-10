package exception;

class ScriptError {
    public final message:String;
    public final script:String;

    public function new(message:String, scriptName:String) {
        this.message = message;
        this.script = scriptName;
    }
}