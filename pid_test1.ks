lock STEERING to UP.

set Kp to 0.05.
set Ki to 0.0002.
set Kd to 0.02.

set thr_pid to PIDLOOP(Kp,Ki,Kd).
set thr_pid:SETPOINT to -5.

stage.
set var_thr to 0.
lock THROTTLE to var_thr.

until ship:altitude > 2000 {
	set x to thr_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
	set var_thr to MAX(var_thr+x,0).
	print x at (0,0).
	print var_thr at (0,1).
	print SHIP:VERTICALSPEED at (0,2).
	wait 0.001.
}