//===================================================
// Channels for minimum HH models in Popischill 2008
// modified from genesis/scripts/neuron/channels.g
// note: used l'hopital rule on tabchannel defs 
// remove singularity to prevent runtime error 
//===================================================

float ECa       = 0.120
float Vx 		= 2e-3    

//=================================================
//           CaL CHANNEL (Reuveni 1993)
//=================================================
function make_CaL
    create tabchannel CaL
    setfield ^ Ek {ECa} Gbar {1} Xpower 2 Ypower 1 Zpower 0

	int   xdivs=5000
    float xmin=-0.100, xmax=0.050, dx={(xmax-xmin)/xdivs}
    call CaL TABCREATE X {xdivs} {xmin} {xmax}
	call CaL TABCREATE Y {xdivs} {xmin} {xmax}

	float valX_A, valX_B, valY_A, valY_B, Vm
	int i		 
    for (i=0; i<={xdivs}; i=i+1)
        Vm = xmin + i*dx
        valX_A = -0.055e6*(Vm+Vx+27e-3)/({exp {(Vm+Vx+27e-3)/-3.8e-3}}-1)
        valX_B = 0.94e3*{exp {(Vm+Vx+75e-3)/-17e-3}} 
        valY_A = 0.000457e3*{exp {(Vm+Vx+13e-3)/-50e-3}} 
        valY_B = 0.0065e3/({exp {(Vm+Vx+15e-3)/-28e-3}}+1)
        if (({exp {(Vm+Vx+27e-3)/-3.8e-3}}-1)==0)
            valX_A = -0.055e6/(1/-3.8e-3*{exp {(Vm+Vx+27e-3)/-3.8e-3}})
        end
        setfield CaL X_A->table[{i}] {valX_A} X_B->table[{i}] {valX_B}
        setfield CaL Y_A->table[{i}] {valY_A} Y_B->table[{i}] {valY_B}
    end
	tweakalpha CaL X
	tweakalpha CaL Y
end

// make channel
make_CaL

