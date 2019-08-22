function getBurnTime {
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

	local g IS body:mu / (altitude + body:radius)^2.                 // Gravitational acceleration constant (m/s²)

	return g * m * p * (1 - e^(-dV/(g*p))) / f.
}

function orbitEcc {
	parameter mnv.

	add mnv.
	local score is mnv:ORBIT:ECCENTRICITY.
	remove mnv.
	return score.
}

function orbitVel {
    parameter r.

    local curr_body is ORBIT:BODY.

    return sqrt(constant():G*curr_body:MASS/(r+curr_body:RADIUS)).
}

function hohmannVel {
    parameter r2.

    local r1 is ALTITUDE + ORBIT:BODY:RADIUS.
    return sqrt(ORBIT:BODY:MU/(r1))*(sqrt(2*r2(r1+r2))-1).
}
