// genesis - sample currents from dendrite

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

//===============================
// Main Script
//===============================

// set voltage
set_voltage {files_voltage}

// some vars
float pi = 3.14, SA = pi*len*dia, SA1 = pi*len1*dia1, XA = pi*dia*dia/4, XA1 = pi*dia1*dia1/4

// Make the cell
create neutral /cell
create compartment /cell/soma 
create compartment /cell/dend 
setfield /cell/soma dia {dia}  len {len}  Em {Em0} Cm {CM0*SA}  Rm {RM0/SA}  Ra {RA0*len/XA}
setfield /cell/dend dia {dia1} len {len1} Em {Em0} Cm {CM0*SA1} Rm {RM0/SA1} Ra {RA0*len1/XA1}

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
addmsg V_0 /cell/dend AXIAL output
step 100 -t 
deletemsg /cell/dend 0 -incoming -find V_0 AXIAL

// Save initial state
save /cell/## {dir_out}/dend.save 

// Output voltages from each compartment
output_sim {dir_out} data_Vd.dat /cell/dend Vm

// Run sim
int i
for (i=1; i<={countelementlist /V_#}-1; i=i+1)
	reset
	restore {dir_out}/dend.save
	addmsg "V_"{i} /cell/dend AXIAL output
	setclock 0 {dt}
	step {tmax} -t
	deletemsg /cell/dend 0 -incoming -find "V_"{i} AXIAL
end

quit
