RUNONCEPATH("lib/stage_lib").

function burnTime {
	parameter dV.
	
	list ENGINES in eng_list.

	local f IS SHIP:AVAILABLETHRUST * 1000.  // Engine Thrust (kg * m/s²)
	local m IS SHIP:MASS * 1000.        // Starting mass (kg)
	local e IS CONSTANT():E.            // Base of natural log
	
	local p IS 0.               // Engine ISP (s)
	for en in eng_list {
		if en:IGNITION and not en:FLAMEOUT {
			set p to p + (en:ISP * (en:AVAILABLETHRUST / SHIP:AVAILABLETHRUST)).
		}
	}
	
	local g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

	return g * m * p * (1 - e^(-dV/(g*p))) / f.
}

function modBurnTime {
	parameter dV.
	
	list ENGINES in eng_list.
	until burnTime(dV) > 10 {
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

function delimitEng {
	list ENGINES in eng_list.
	for en in eng_list {
			set en:THRUSTLIMIT to 100.0.
	}	
}

function execMnv {	//Execute a maneuver (time, rad, nor, pro)
	parameter mnv.
	
	lock THROTTLE to 0.
	local l_mnv is mnv.
	
	//print l_mnv:DELTAV:DIRECTION.
	//print l_mnv:DELTAV:MAG.
	local burn_time is burnTime(l_mnv:DELTAV:MAG).
	modBurnTime(l_mnv:DELTAV:MAG).
	//print "BURN: " + burnTime(l_mnv:DELTAV:MAG).
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
//set mm to node(mnv[0],mnv[1],mnv[2],mnv[3])
set exe_node to NEXTNODE.
execMnv(exe_node).
REMOVE exe_node.