RUNONCEPATH("lib/lib_vec").
RUNONCEPATH("lib/lib_physics").

function isExecDone {
	parameter mnv.

	if not(defined origin_vec) or origin_vec = -1 {
		declare global origin_vec to mnv:BURNVECTOR.
	}
	if vang(origin_vec, mnv:BURNVECTOR) > 90 {
		declare global origin_vec to -1.
		return true.
	}
	return false.
}

function execMnv {	//Execute a maneuver (time, rad, nor, pro)
	parameter mnv.

	function modBurnTime {
		parameter dV.

		list ENGINES in eng_list.
		until getBurnTime(dV) > 10 {
			for en in eng_list {
				if en:IGNITION and not en:FLAMEOUT {
					if en:THRUSTLIMIT<10 {
						return.
					}
					set en:THRUSTLIMIT to en:THRUSTLIMIT - 5.
				}
			}
			wait 0.001.
		}
	}
	function delimitEng {
		list ENGINES in eng_list.
		for en in eng_list {
				set en:THRUSTLIMIT to 100.0.
		}
	}

	lock THROTTLE to 0.
	local l_mnv is mnv.

	//print l_mnv:DELTAV:DIRECTION.
	//print l_mnv:DELTAV:MAG.
	local burn_time is getBurnTime(l_mnv:DELTAV:MAG).
	modBurnTime(l_mnv:DELTAV:MAG).
	//print "BURN: " + getBurnTime(l_mnv:DELTAV:MAG).
	lock STEERING to l_mnv:DELTAV:DIRECTION.
	wait 5.
	local time_to_burn is time:SECONDS + l_mnv:ETA - burn_time/2.
	if (time:SECONDS < time_to_burn) {
		kuniverse:TIMEWARP:WARPTO(time_to_burn).
		wait until time:SECONDS >= time_to_burn.
		lock THROTTLE to 1.
		until isExecDone(l_mnv) {
			autoStage().
			wait 0.001.
		}
		lock THROTTLE to 0.
	}
	print "DONE".
	delimitEng().
}

function circulariseBurn {

	local deltaV is orbitVel(ORBIT:APOAPSIS) - ORBIT:VELOCITY:ORBIT.

	local l_mnv is NODE(time:SECONDS+ETA:APOAPSIS,0,0,deltaV).
	add l_mnv.
	execMnv(l_mnv).
	remove l_mnv.
}

function pidDescent {
	parameter vel.

	clearscreen.

	set dir to UP.
	lock STEERING to dir.
	wait 2.

	set Kp to 0.4.
	set Ki to 0.1.
	set Kd to 0.05.
	set min_o to 0.
	set max_o to 1.

	set thr_pid to PIDLOOP(Kp,Ki,Kd,min_o,max_o).
	set thr_pid:SETPOINT to -vel.

	set pitch_pid to PIDLOOP(5.0,0.00,0.01,-35,35).
	set pitch_pid:SETPOINT to 0.

	set yaw_pid to PIDLOOP (5.0,0.00,0.01,-35,35).
	set yaw_pid:SETPOINT to 0.



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
}

function hoverSlamHeight {

	local grav is constant(): g * (body:mass / body:radius^2).
	local max_dec is (SHIP:AVAILABLETHRUST / SHIP:MASS) - grav.
	set stop_dist to SHIP:VERTICALSPEED^2 / (2*max_dec).
	print stop_dist at (10,10).
	print ALT:RADAR at (10,11).
	print ROUND(MAX(0.001,((ALTITUDE-GEOPOSITION:TERRAINHEIGHT)-50)),3) at (10,12).

	return stop_dist.//+(SHIP:GROUNDSPEED^2 / (2*AVAILABLETHRUST/MASS))^2).
}

function hoverSlam {
	lock THROTTLE to 0.
	wait until SHIP:VERTICALSPEED<0.
	SAS off.
	lock STEERING to SRFRETROGRADE.
	wait until getSurfHeight()<(hoverSlamHeight()+50).
	until SHIP:VERTICALSPEED>-5 {
		lock THROTTLE to 1.
		wait 0.001.
	}

	GEAR ON.
	lock THROTTLE to 0.
	pidDescent(3).
}

function hohmannTranferMnv {
	parameter r.

	until (ORBIT:APOAPSIS)*0.95<(ORBIT:PERIAPSIS) {
		circulariseBurn().
	}
	local deltaV is hohmannVel(r).
	local l_mnv is NODE(TIME:SECONDS+ETA:APOAPSIS,0,0,deltaV).
	add l_mnv.
	execMnv(l_mnv).
	remove l_mnv.
	circulariseBurn().
}
