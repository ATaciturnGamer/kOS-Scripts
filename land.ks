RUNONCEPATH("lib/lib_mnv").

//SAS off.
//lock STEERING to SRFRETROGRADE.
//until SHIP:VERTICALSPEED>-10 {
//	lock THROTTLE to 1.
//	wait 0.001.
//}
//GEAR ON.
//lock THROTTLE to 0.
//runpath("pid_test1.ks").
print hoverSlamHeight().
hoverSlam().