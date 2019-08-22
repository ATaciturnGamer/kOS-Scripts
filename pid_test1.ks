RUNONCEPATH("lib/lib_vec").

clearscreen.

set dir to UP.
lock STEERING to dir.
wait 2.

set Kp to 0.05.
set Ki to 0.02.
set Kd to 0.01.
set min_o to 0.
set max_o to 1. 

set thr_pid to PIDLOOP(Kp,Ki,Kd,min_o,max_o).
set thr_pid:SETPOINT to -5.

set pitch_pid to PIDLOOP(5.0,0.05,0.1,-35,35).
set pitch_pid:SETPOINT to 0.

set yaw_pid to PIDLOOP (5.0,0.05,0.1,-35,35).
set yaw_pid:SETPOINT to 0.



stage.
set var_thr to 0.
lock THROTTLE to var_thr.

until ship:status = "landed" {
	set x to thr_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
	set var_thr to MAX(x,0).
	
	set pit to pitch_pid:UPDATE(TIME:SECONDS,-getSurfVelocity()[1]).
	set yaw to yaw_pid:UPDATE(TIME:SECONDS,-getSurfVelocity()[0]).
	set dir to UP+R(yaw,pit,0).//HEADING(90+yaw,90+pit).
	
	print x at (0,0).
	print "PITCH: "+ pit at (0,2).
	print "YAW:   "+ yaw at (0,3).
	print "Z:     "+SHIP:VERTICALSPEED at (0,4).
	print "Y:     "+getSurfVelocity()[1] at (0,5).
	print "X:     "+getSurfVelocity()[0] at (0,6).
	wait 0.001.
}