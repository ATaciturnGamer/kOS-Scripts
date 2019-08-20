RUNONCEPATH("lib/stage_lib").

function orbitEcc {
	parameter mnv.
	
	add mnv.
	local score is mnv:ORBIT:ECCENTRICITY.
	remove mnv.
	return score.
}

function incPrograde {
	parameter mnv.
	parameter step.
	
	local oldScore is orbitEcc(mnv).
	local oldMnv is mnv.
	
	local newMnv is node(time:SECONDS+mnv:ETA,0,0,mnv:PROGRADE+step).
	local newScore is orbitEcc(newMnv).
	return newMnv.
	
}

function hillClimbPrograde {
	parameter utime.
	
	local l_mnv is node(utime,0,0,0).
	local step is 1.
	local bestScore is orbitEcc(l_mnv).
	
	local n_mnv is incPrograde(l_mnv,step).
	local newScore is orbitEcc(n_mnv).
	print bestScore+" "+newScore.
	
	until newScore>=bestScore and abs(step) = 1
	{
		if newScore<bestScore {
			set l_mnv to n_mnv.
			set bestScore to newScore.
			if abs(step) >= 1 and abs(step)<50{
				set step to step*2.
			}
		}
		else{
			set step to step/2.
		}
		set n_mnv to incPrograde(l_mnv,step).
		set newScore to orbitEcc(n_mnv).
		//print step+" "+ l_mnv:PROGRADE+" "+ n_mnv:PROGRADE.
		//print bestScore+" "+newScore.
	}
	
	print bestScore.
	add l_mnv.
	
}


clearscreen.

SAS off.
gear off.
set boostersOn to 1.
set thr_val to 1.

set runmode to 1.

until runmode = 0 {
  if runmode = 1 {
    lock STEERING to UP.
    set thr_val to 1.
    stage.
    set runmode to 2.
    print "LIFTOFF!             " at (0,0).
  }
  if runmode = 2 {
    if SHIP:ALTITUDE > 2000 {
      set runmode to 3.
      print "ENGAGING GRAVITY TURN" at (0,0).
    }
    set thr_val to 1.
  }
  if runmode = 3 {
    set pitch_val to max(5,90*(1-(SHIP:ALTITUDE-2000)/50000)).
    lock steering to heading(90,pitch_val).
    set thr_val to 1.
    if SHIP:APOAPSIS>80000 {
		set runmode to 4.
		print "CALCULATING ORBIT VEL" at (0,0).
		hillClimbPrograde(time:SECONDS+ETA:APOAPSIS).
    }
  }
  if runmode = 4 { //COAST to APOAPSIS
    lock STEERING to SHIP:PROGRADE.
    set thr_val to 0.
    print "ENTERING ORBIT       " at (0,0).
	RUNPATH("execMnv.ks").
	set runmode to 5.
  }
  if runmode = 5 { //ORBIT
    lock STEERING to heading(90,0).
    set thr_val to 0.
	if (ETA:APOAPSIS<ETA:PERIAPSIS) {
		print "ROUNDING ORBIT       " at (0,0).
		hillClimbPrograde(time:SECONDS+ETA:APOAPSIS).
		RUNPATH("execMnv.ks").
		set runmode to 0.
	}
  }

  if not (runmode=1) {
    list ENGINES in engine_list.
    for eng in engine_list {
      if eng:FLAMEOUT{
        stage.
        wait until STAGE:READY.
        break.
      }
    }
    PRINT "STAGE "+STAGE:NUMBER at (0,6+STAGE:NUMBER).
  }

  lock THROTTLE to thr_val.
}
unlock STEERING.
unlock THROTTLE.