// genesis - sample currents from channels
// assume channels already created in {loc_chans}

// Output format
addglobal str out_form "%0.15g"
setclock 2 100 // prevents carriage returns from sim_chan

// set voltages: creates tables V_1...V_n (n=nV) of voltages
function set_voltage(files)
if ({strcmp {files} "none"})
	int j, nV={getarg {arglist {files}} -count}
	for (j=1; j<={nV}; j=j+1)
		create table "time"
		call "time" TABCREATE 1 0 1 // default to be overwritten
		str file = {getarg {arglist {files}} -arg {j}}		
		file2tab {file} "time" table -table2 "dummy"
		float tdivs = {getfield time table->xdivs}
		create table "V_"{j}
		call "V_"{j} TABCREATE 1 0 1 // default to be overwritten
		setfield "V_"{j} step_mode 2 stepsize 0
		file2tab {file} "V_"{j} table -xy {tdivs} 
		echo "set V_"{j}" for" {file}
	end
else
	echo "voltage not specified in file"
end
end

// output results: output_Ichan <dir> <file> <loc> <var1> <var2> ...
function output_Ichan(dir,file,loc)	
	str dir, file, loc	
	if (!{exists {file}})  	// create & open asc_file if doesn't exist
		create asc_file {file}
		setfield {file} filename {dir}/{file} leave_open 1 append 1 float_format {out_form}
		call {file} OUT_OPEN	// (careful - think acts as toggle)
	end
    useclock {file} 1
	int i, j, nv=({argc}-3), nchan={countelementlist {loc}/#[CLASS=channel]}
	for (i=1; i<=nchan; i=i+1)		// write header describing channels
		str channel = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}
		float Ek={getfield {channel} Ek}, Gbar={getfield {channel} Gbar}
		float Xp={getfield {channel} Xpower}, Yp={getfield {channel} Ypower}
    	call {file} OUT_WRITE "%" {channel} "Ek" {Ek} "Gbar" {Gbar} "Xpower" {Xp} "Ypower" {Yp}
	end	
	for (i=1; i<={nchan}; i=i+1)	// write header describing vars
		str channel = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}		
		for (j=1; j<={nv}; j=j+1)
			str var = {argv {3+j}}		
			call {file} OUT_WRITE "%" {channel} {var}
		end
	end
	for (i=1; i<={nchan}; i=i+1)	// add message to asc_file from vars	
		str channel = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}		
		for (j=1; j<={nv}; j=j+1)
			str var = {argv {3+j}}		
			addmsg {channel} {file} SAVE {var}
		end
	end
end

function addVmsg(Vtable,loc)
	str Vtable, loc
	int i, nchan={countelementlist {loc}/#[CLASS=channel]}
    for (i=1; i<=nchan; i=i+1)		
        str chan = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}
		addmsg {Vtable} {chan} VOLTAGE output	
	end
end

function delVmsg(Vtable,loc)
	str Vtable, loc
	int i, nchan={countelementlist {loc}/#[CLASS=channel]}
	for (i=1; i<={nchan}; i=i+1)
		str chan = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}
		deletemsg {chan} 0 -incoming -find {Vtable} VOLTAGE
	end
end

// output channels: output_XYchan <dir> <file> <loc>
function output_XYchan(dir,file,loc)
	str dir, file, loc
	if (!{exists {file}})		// create & open asc_file if doesn't exist
		create asc_file {file}
		setfield {file} filename {dir}/{file} notime 1 leave_open 1 append 1 float_format {out_form}
		call {file} OUT_OPEN
	end	
    useclock {file} 2    // HACK - small clock step avoids carriage returns
	int i, j, nchan={countelementlist {loc}/#[CLASS=channel]}
	for (i=1; i<=nchan; i=i+1)		// write header describing channels
		str channel = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}
		float Ek={getfield {channel} Ek}, Gbar={getfield {channel} Gbar}
		float Xp={getfield {channel} Xpower}, Yp={getfield {channel} Ypower}
    	call {file} OUT_WRITE "%" {channel} "Ek" {Ek} "Gbar" {Gbar} "Xpower" {Xp} "Ypower" {Yp}
	end	
	for (i=1; i<=nchan; i=i+1)		// loop through channels
		str channel = {getarg {el {loc}/#[CLASS=channel]} -arg {i}}
		float X_alloced={getfield {channel} X_alloced}, Y_alloced={getfield {channel} Y_alloced}
		if (X_alloced)			// find voltage range of channel
			float xmin={getfield {channel} X_A->xmin}, dx={getfield {channel} X_A->dx}
			float xdivs={getfield {channel} X_A->xdivs}
		elif (Y_alloced)
			float xmin={getfield {channel} Y_A->xmin}, dx={getfield {channel} Y_A->dx}
			float xdivs={getfield {channel} Y_A->xdivs}
		else					// flag up if both X & Y undefined
			echo {channel} "undefined"
			return
		end
		for (j=0; j<={xdivs}; j=j+1)			// loop through voltage vals
			if (X_alloced)						// find X
				float x_A={getfield {channel} X_A->table[{j}]}
				float x_B={getfield {channel} X_B->table[{j}]}
			else
				str x_A="nan", x_B="nan"
			end
			if (Y_alloced)						// find Y
				float y_A={getfield {channel} Y_A->table[{j}]}
				float y_B={getfield {channel} Y_B->table[{j}]}
			else
				str y_A="nan", y_B="nan"
			end									// then write to file
			call {file} OUT_WRITE {xmin+dx*j} {x_A} {x_B} {y_A} {y_B}
		end
	end
end

//===============================
// Main Script
//===============================

// set voltage
set_voltage {files_voltage}

// Simulation variables
float V0 = {getfield V_1 table->table[0]} 
float tmax = {getfield V_1 table->xmax} 
float dt = {getfield V_1 table->dx} 
setclock 1 {dt}

// Initial voltage input
create table V_0
call V_0 TABCREATE 1 1 1 
setfield V_0 step_mode 1 table->table[0] {V0} table->table[1] {V0}

// Initialise sim 
reset 
setclock 0 {100*dt}
addVmsg V_0 {loc_chans} 
step 100 -t 
delVmsg V_0 {loc_chans} 

// Save initial state
save {loc_chans}/## {dir_out}/chans.save 

// Output channel dynamics
output_Ichan {dir_out} data_Ik.dat {loc_chans} Ik
output_Ichan {dir_out} data_Xk.dat {loc_chans} X
output_Ichan {dir_out} data_Yk.dat {loc_chans} Y
output_XYchan {dir_out} data_XY.dat {loc_chans}

// Run sim
int i
for (i=1; i<={countelementlist /V_#}-1; i=i+1)
	reset
	restore {dir_out}/chans.save
	addVmsg "V_"{i} {loc_chans} 
	setclock 0 {dt}
	step {tmax} -t
	delVmsg "V_"{i} {loc_chans} 
end

quit

