//===================================================
// Channels for minimum HH models in Popischill 2008
// modified from genesis/scripts/neuron/channels.g
// note: used l'hopital rule on tabchannel defs 
// remove singularity to prevent runtime error 
//===================================================
 
float EK        = -0.090
float V_T  		= -65e-3

//=================================================
//           Kd CHANNEL (Traub, Miles 1991)
//=================================================
function make_Kd 
    create tabchannel Kd
    setfield ^ Ek {EK} Gbar {50} Xpower 4 Ypower 0 Zpower 0

	int   xdivs=5000
	float xmin=-0.100, xmax=0.050, dx={(xmax-xmin)/xdivs}
	call Kd TABCREATE X {xdivs} {xmin} {xmax}

	float valX_A, valX_B, Vm
	int i		 
	for (i=0; i<={xdivs}; i=i+1)
		Vm = xmin + i*dx
		valX_A = -0.032e6*(Vm-V_T-15e-3)/({exp {(Vm-V_T-15e-3)/-5e-3}}-1)
		valX_B = 0.5e3*{exp {(Vm-V_T-10e-3)/-40e-3}} 
		if ({({exp {(Vm-V_T-15e-3)/-5e-3}}-1)}==0)
	    	 valX_A = -0.032e6/(1/-5e-3*{exp {(Vm-V_T-15e-3)/-5e-3}})
		end
		setfield Kd X_A->table[{i}] {valX_A} X_B->table[{i}] {valX_B}
	end
	tweakalpha Kd X
end

// make channel
make_Kd
