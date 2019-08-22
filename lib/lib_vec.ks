function getSurfHeight {
	return ROUND(MAX(0.001,((ALTITUDE-GEOPOSITION:TERRAINHEIGHT)-50)),3).
}

function getSurfVelocity {

	local sinYaw is sin(ship:up:yaw).
	local cosYaw is cos(ship:up:yaw).
	local sinPitch is sin(ship:up:pitch).
	local cosPitch is cos(ship:up:pitch).

	set unitVectorEast to V(-cosYaw, 0, sinYaw).
	set unitVectorNorth to V(-sinYaw*sinPitch, cosPitch, -cosYaw*sinPitch).
	set shipVelocitySurface to ship:velocity:surface.
	set speedEast to vdot(shipVelocitySurface, unitVectorEast).
	set speedNorth to vdot(shipVelocitySurface, unitVectorNorth).
	return list(speedNorth,speedEast).
}