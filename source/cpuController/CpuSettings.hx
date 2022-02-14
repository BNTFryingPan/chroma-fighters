package cpuController;

enum abstract CPU_LEVEL(Int) to Int {
   var LV0; // no ai? just stands there
   var LV1;
   var LV2;
   var LV3;
   var LV4;
   var LV5;
   var LV6;
   var LV7;
   var LV8;
   var LV9;
}

enum CpuAction {
   NONE;
   CROUCH;
   JUMP;
   RUN;
   PARRY;
   ROLL;
   FIGHT;
   EVADE;
   CONTROL;
}

class CpuSettings {
   public function new(lv:CPU_LEVEL = LV5, action:CpuAction = NONE) {}
}
