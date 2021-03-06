function eta_true_anom {
	declare local parameter tgt_lng.
	local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
	local node_true_anom to (mod (720+ tgt_lng - (obt:lan + obt:argumentofperiapsis),360)).
	local node_eta to 0.
	local ecc to OBT:ECCENTRICITY.
	if ecc < 0.001 {
		set node_eta to SHIP:OBT:PERIOD * ((mod(tgt_lng - ship_ref + 360,360))) / 360.
	} else {
		local eccentric_anomaly to  arccos((ecc + cos(node_true_anom)) / (1 + ecc * cos(node_true_anom))).
		local mean_anom to (eccentric_anomaly - ((180 / (constant():pi)) * (ecc * sin(eccentric_anomaly)))).
		local time_2_anom to  SHIP:OBT:PERIOD * mean_anom /360.
		local my_time_in_orbit to ((OBT:MEANANOMALYATEPOCH)*OBT:PERIOD /360).
		set node_eta to mod(OBT:PERIOD + time_2_anom - my_time_in_orbit,OBT:PERIOD) .
	}
	return node_eta.
}

function set_inc_lan {
	DECLARE PARAMETER incl_t.
	DECLARE PARAMETER lan_t is 0.
	local incl_i to SHIP:OBT:INCLINATION.
	local lan_i to SHIP:OBT:LAN.
	local Va to V(sin(incl_i)*cos(lan_i+90),sin(incl_i)*sin(lan_i+90),cos(incl_i)).
	local Vb to V(sin(incl_t)*cos(lan_t+90),sin(incl_t)*sin(lan_t+90),cos(incl_t)).
	local Vc to VCRS(Vb,Va).
	local dv_factor to 1.
	local node_lng to mod(arctan2(Vc:Y,Vc:X)+360,360).
	local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
	local ship_2_node to mod((720 + node_lng - ship_ref),360).
	if ship_2_node > 180 {
		set dv_factor to -1.
		set node_lng to mod(node_lng + 180,360).
	}       
	local node_true_anom to 360- mod(720 + (obt:lan + obt:argumentofperiapsis) - node_lng , 360 ).
	local ecc to OBT:ECCENTRICITY.
	local my_radius to OBT:SEMIMAJORAXIS * (( 1 - ecc^2)/ (1 + ecc*cos(node_true_anom)) ).
	local my_speed1 to sqrt(SHIP:BODY:MU * ((2/my_radius) - (1/OBT:SEMIMAJORAXIS)) ).   
	local node_eta to eta_true_anom(node_lng).
	local my_speed to VELOCITYAT(SHIP, time+node_eta):ORBIT:MAG.
	local d_inc to arccos (vdot(Vb,Va) ).
	local dvtgt to dv_factor* (2 * (my_speed) * SIN(d_inc/2)).
	local inc_node to NODE(node_eta, 0, 0, 0).
	set inc_node:NORMAL to dvtgt * cos(d_inc/2).
	set inc_node:PROGRADE to 0 - abs(dvtgt * sin(d_inc/2)).
	set inc_node:ETA to node_eta.
	add inc_node.
}

export(0).