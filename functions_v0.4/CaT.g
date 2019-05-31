//===================================================
// Channels for minimum HH models in Popischill 2008
// modified from genesis/scripts/neuron/channels.g
// note: used l'hopital rule on tabchannel defs 
// remove singularity to prevent runtime error 
//===================================================

float ECa       = 0.120
float Vx 		= 2e-3    

//=================================================
//           CaT CHANNEL (Destexhe 1996)
//=================================================
function make_CaT
    create tabchannel CaT
    setfield ^ Ek {ECa} Gbar {1} Xpower 2 Ypower 1 Zpower 0
    setfield CaT instant {INSTANTX}

	 int   xdivs=5000
	 float xmin=-0.100, xmax=0.050, dx={(xmax-xmin)/xdivs}
	 call CaT TABCREATE X {xdivs} {xmin} {xmax}
     call CaT TABCREATE Y {xdivs} {xmin} {xmax}
    
	 float valtau_X, valX_inf, valtau_Y, valY_inf, Vm
	 int i		 
	 for (i=0; i<={xdivs}; i=i+1)
	 	 Vm = xmin + i*dx
	 	 valtau_X = 1e-3  // fake value - instant 
	 	 valX_inf = 1/(1+{exp {-(Vm+Vx+57e-3)/6.2e-3}})
	 	 valtau_Y = (30.8 + (211.4 + {exp {(Vm+Vx+113.2e-3)/5e-3}}))/(3.7*(1 + {exp {(Vm+Vx+84e-3)/3.2e-3}}))
		 valY_inf = 1/( 1 + { exp {(Vm+Vx+81e-3)/4e-3} } )
		 setfield CaT X_A->table[{i}] {valtau_X} X_B->table[{i}] {valX_inf}
       setfield CaT Y_A->table[{i}] {valtau_Y} Y_B->table[{i}] {valY_inf}
	 end
	 tweaktau CaT X
     tweaktau CaT Y
end

// make channel
make_CaT
