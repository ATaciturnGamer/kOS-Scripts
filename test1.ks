lock sinYaw to sin(ship:up:yaw).
lock cosYaw to cos(ship:up:yaw).
lock sinPitch to sin(ship:up:pitch).
lock cosPitch to cos(ship:up:pitch).

lock unitVectorEast to V(-cosYaw, 0, sinYaw).
lock unitVectorNorth to V(-sinYaw*sinPitch, cosPitch, -cosYaw*sinPitch).
lock shipVelocitySurface to ship:velocity:surface.
lock speedEast to vdot(shipVelocitySurface, unitVectorEast).
lock speedNorth to vdot(shipVelocitySurface, unitVectorNorth).
clearscreen.
until false {
	print speedEast at (0,0).
	print speedNorth at (0,1).
	wait 0.01.
}