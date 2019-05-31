// genesis - simulate 2-cpt neuron with active soma, passive dendrite

maxwarnings 100

// Output format
addglobal str out_form "%0.15g"
setclock 2 100 // prevents carriage returns from sim_chan

// set injection current: creates tables inject_1...inject_n (n=ninj) of injection currents
// note: requires scanned table to start at time zero
function set_inject(files)
if ({strcmp {files} "none"})
	int j, ninj={getarg {arglist {files}} -count}
	for (j=1; j<={ninj}; j=j+1)
		create table "time"
		call "time" TABCREATE 1 0 1 // default to be overwritten
		str file = {getarg {arglist {files}} -arg {j}}		
		file2tab {file} "time" table -table2 "dummy"
		float tdivs = {getfield time table->xdivs}
		create table "inject_"{j}		
		call "inject_"{j} TABCREATE 1 0 1 // default to be overwritten
		setfield "inject_"{j} step_mode 2 stepsize 0
		file2tab {file} "inject_"{j} table -xy {tdivs}
		echo "set inject_"{j}" for" {file}
	end
else
	echo "injection current not specified in file"
end
end

// output params: output_params <dir> <file> <object> <var1> <var2> ...
function output_params(dir,file,object,var)
	str dir, file, object, var
	if (!{exists {file}})  	// create & open asc_file if doesn't exist
		create asc_file {file}
		setfield {file} filename {dir}/{file} leave_open 1 append 1 float_format {out_form}
		call {file} OUT_OPEN	// (careful - think acts as toggle)
	end
	int i, nv=({argc}-3)
	for (i=1; i<={nv}; i=i+1)	// iterate through variables
		str var = {argv {3+i}}	// ... and write value to file
		call {file} OUT_WRITE "%" {object} {var} {getfield {object} {var}}
	end
end

// output morphology: output_mrphgy <dir> <file> <cpmpt> 
function output_mrphgy(dir,file,cpmnt)
	str dir, file, cpmnt, cpmnt1, lij, lji
	if (!{exists {file}})  	// create & open asc_file if doesn't exist
		create asc_file {file}
		setfield {file} filename {dir}/{file} leave_open 1 append 1 float_format {out_form}
		call {file} OUT_OPEN	// (careful - think acts as toggle)
	end
	int i, ncpmnt={countelementlist /cell/##[CLASS=membrane]} // # cpmnts
	for (i=1; i<=ncpmnt; i=i+1) // iterate through compartments
		cpmnt1 = {getarg {el /cell/##[CLASS=membrane]} -arg {i}} 
        lij = {{getmsg {cpmnt} -in -find {cpmnt1} RAXIAL}>0}
        lji = {{getmsg {cpmnt1} -in -find {cpmnt} RAXIAL}>0}
		call {file} OUT_WRITE "%" {cpmnt} {cpmnt1} {lij+lji}
	end
end

// output results: output_sim <dir> <file> <object> <var1> <var2> ...
function output_sim(dir,file,object,var)	
	str dir, file, object, var
	if (!{exists {file}})  	// create & open asc_file if doesn't exist
		create asc_file {file}
		setfield {file} filename {dir}/{file} leave_open 1 append 1 float_format {out_form}
		call {file} OUT_OPEN	// (careful - think acts as toggle)
	end
    useclock {file} 1
	int i, nv=({argc}-3)
	for (i=1; i<={nv}; i=i+1)	// write header describing vars
		str var = {argv {3+i}}		
		call {file} OUT_WRITE "%" {object} {var}
	end
	for (i=1; i<={nv}; i=i+1)	// iterate through variables	
		str var = {argv {3+i}}	// ... and add message to asc_file
		addmsg {object} {file} SAVE {var}
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

// set injection current
set_inject {files_inject}

// Morphological parameters
float pi = 3.14, SA = pi*len*dia, SA1 = pi*len1*dia1, XA = pi*dia*dia/4, XA1 = pi*dia1*dia1/4

// Make the cell
create neutral /cell
create compartment /cell/soma 
create compartment /cell/dend 
setfield /cell/soma dia {dia}  len {len}  Em {Em0} Cm {CM0*SA}  Rm {RM0/SA}  Ra {RA0*len/XA}
setfield /cell/dend dia {dia1} len {len1} Em {Em0} Cm {CM0*SA1} Rm {RM0/SA1} Ra {RA0*len1/XA1}
addmsg /cell/dend /cell/soma RAXIAL Ra previous_state
addmsg /cell/soma /cell/dend AXIAL previous_state

// Add channels to soma
int j, nchans={countelementlist {loc_chans}/[CLASS=channel]}	
for (j=1; j<={nchans}; j=j+1)
    str chan = {getarg {el {loc_chans}/[CLASS=channel]} -arg 1}
    setfield {chan} Gbar {{getarg {arglist {G}} -arg {j}}*SA}
    addmsg {chan} /cell/soma CHANNEL Gk Ek
    addmsg /cell/soma {chan} VOLTAGE Vm
    move {chan} /cell/soma
end

// Initialise sim 
check
reset 
setclock 0 {100*dt}
setfield /cell/soma inject {getfield inject_1 table->table[0]} // init inj current
step 100 -t 

// Output results from all compartments to text file 
str file="data_IV.dat", cpmnt
int i, ncpmnt={countelementlist /cell/##[CLASS=membrane]} // # cpmnts
for (i=1; i<=ncpmnt; i=i+1) // iterate through compartments
	cpmnt = {getarg {el /cell/##[CLASS=membrane]} -arg {i}} 
	output_params {dir_out} {file} {cpmnt} Em Rm Cm Ra len dia // passive params
	output_mrphgy {dir_out} {file} {cpmnt}  // morphology
end    
output_sim {dir_out} {file} /cell/soma inject // injection current
for (i=1; i<=ncpmnt; i=i+1) // iterate through other compartments
    cpmnt = {getarg {el /cell/##[CLASS=membrane]} -arg {i}} 
	output_sim {dir_out} {file} {cpmnt} Vm
end

// Output channel defns to text file 
output_XYchan {dir_out} data_XY.dat /cell/soma

// Save initial state (user defined dir - using same as output_results)
save /cell/## {dir_out}/mycell.save 

// Run sim
int i
for (i=1; i<={countelementlist /inject_#}; i=i+1)
	reset
	setclock 0 {dt}
	restore {dir_out}/mycell.save
	addmsg "inject_"{i} /cell/soma INJECT output // created by set_params
	step {getfield inject_1 table->xmax} -t // tmax from injection current
	deletemsg /cell/soma 0 -incoming -find "/inject_"{i} INJECT
end

quit
