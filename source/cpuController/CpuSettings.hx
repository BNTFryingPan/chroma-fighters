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

/*
   training mode action. has no effect in normal matches
 */
enum CpuAction {
   NONE;
   CROUCH;
   JUMP;
   RUN;
   PARRY;
   ROLL;
   FIGHT; // uses regular cpu ai
   EVADE;
   CONTROL;
}

enum CpuTeching {
   DONT_ROLL;
   ROLL_IN;
   ROLL_OUT;
   ROLL_IN_PLACE;
}

class CpuSettings {
   public var level:CPU_LEVEL;
   public var action:CpuAction = NONE;
   public var tech:CpuTeching = ROLL_IN_PLACE;

   public function new(lv:CPU_LEVEL = LV5, action:CpuAction = JUMP) {
      this.level = lv;
      this.action = action;
   }

   public function shouldProcessCpuInput():Bool {
      if (this.action == NONE)
         return false;
      if (this.level == LV0)
         return false;
      return true;
   }
}
