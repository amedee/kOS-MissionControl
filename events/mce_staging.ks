local mce_staging is list("mce_staging", {if throttle > 0 {if availablethrust = 0 and sn = fine {stage. lock throttle to 0.} else if sn = 0 and availablethrust = 0 {hudtext("WARNING: Engine Thrust Unavailable",10,4,25,red,false). lock throttle to 0.} else if sn > fine {list engines in eng.	for e in eng if e:stage = sn and e:ignition and e:flameout {stage. wait 1. if availablethrust = 0 and sn > fine stage. break.}}}}).