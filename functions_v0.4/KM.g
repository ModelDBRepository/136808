//===================================================
// Channels for minimum HH models in Popischill 2008
// modified from genesis/scripts/neuron/channels.g
// note: used l'hopital rule on tabchannel defs 
// remove singularity to prevent runtime error 
//===================================================

float EK       = -0.090
float tau_max  = 4

//=================================================
//           KM CHANNEL (Yamada 1989)
//=================================================
function make_KM
   create tabchannel KM
   setfield ^ Ek {EK} Gbar {0.8} Xpower 1 Ypower 0 Zpower 0

	int   xdivs=5000
	float xmin=-0.100, xmax=0.050, dx={(xmax-xmin)/xdivs}
	call KM TABCREATE X {xdivs} {xmin} {xmax}

	float valtau_X, valX_inf, Vm
	int i		 
	for (i=0; i<={xdivs}; i=i+1)
	   Vm = xmin + i*dx
	   valtau_X = tau_max/(3.3*{exp {(Vm+35e-3)/20e-3}} + {exp {-(Vm+35e-3)/20e-3}})
	   valX_inf = 1/(1+{exp {-(Vm+35e-3)/10e-3}})
	   setfield KM X_A->table[{i}] {valtau_X} X_B->table[{i}] {valX_inf}
	end
	tweaktau KM X
end

// make channel
make_KM
