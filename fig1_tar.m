function fig1_tar
% example data: 1 active 1 passive compartment

clear all; dbstop if error; clc;
fpath = 'functions_v0.4'; path(path,fpath); 
% cpath = '../compiled_v0.4'; path(path,cpath); 
res = [pwd,'/',mfilename]; if ~isdir(res); mkdir(res); end
% if isdir('/output'); rmdir('/output','s'); end; 
mkdir('output');

% function to convert 1cpt->2cpt
function [len,dia] = match(len0,dia0,la,mu) % la=Sd/Ss, mu=S0/Ss 
    si = 1/(mu-1)-1/la; % si=Rax/Rs
    dia(1) = sqrt(1/mu)*dia0; len(1) = sqrt(1/mu)*len0; 
    S0 = pi*len0*dia0; SA(1) = S0/mu; SA(2,1) = SA(1)*la; Rax = si*RM/SA(1);
    dia(2,1) = (4*RA*SA(2)/(pi^2*Rax))^(1/3); len(2,1) = SA(2)/(pi*dia(2));
%     % display some outputs
%     ldSa = [round(len*1e6), round(dia*1e6), round(SA*1e12)]'
%     tau = round(1e3*[CM*RM, CM*RM/(1+(RM/SA(1)+RM/SA(2))/Rax)])
%     scRax = round(1e-6*Rax)
%     Rin = round(1e-6*RM./(pi*len0.*dia0))
end

%% generate data_pop1 - pospischil fig0
name = 'pop1';

% parameters
pas_param = [res,'/pas_param_',name]; 
CM = 0.01; RM = 0.667; RA = 10; Em = -0.065; 
[len,dia] = match(67e-6,67e-6,2,2); % 1 1.6
save(pas_param,'CM','RM','RA','Em','len','dia');

act_param = [res,'/act_param_',name]; 
G = [500 100]; chan_list = {'Na','Kd'}; Vhalf = [0 0; 0 0];
V_T = 15e-3; chan_sc = [V_T,1,1, V_T,1,1; V_T,1,1, V_T,1,1]; % Vsh, Vsc, tc 
save(act_param,'G','chan_list','chan_sc','Vhalf');

sim_param = [res,'/sim_param_',name]; 
dt_out = 5e-5; dt_sim = 2e-6; tmax = 0.5; 
save(sim_param,'dt_out','dt_sim','tmax');

IV_data = [res,'/IV_data_',name]; 
tinj = (0:dt_out:0.5)'; % same sampling as output
Iinj = 0.5e-9*( tinj>=0.1 & tinj <=0.4 );
t = tinj; Vs = tinj*nan;
save(IV_data,'tinj','Iinj','t','Vs');

% make the data
id = [res,'/IV_tar_',name];
pars{1} = {id,IV_data,pas_param,act_param,sim_param};    
makeCell_1act1pas(id,IV_data,pas_param,act_param,sim_param)

%% generate data_pop2 - pospischil fig1
name = 'pop2';

% parameters
pas_param = [res,'/pas_param_',name]; 
CM = 0.01; RM = 1; RA = 10; Em = -0.070; 
[len,dia] = match(96e-6,96e-6,2,2);
save(pas_param,'CM','RM','RA','Em','len','dia');

act_param = [res,'/act_param_',name]; 
G = [500 50 0.7]; chan_list = {'Na','Kd','KM'}; Vhalf = [0 0; 0 0; 0 0];
V_T = 5e-3; chan_sc = [V_T,1,1, V_T,1,1; V_T,1,1, V_T,1,1; 0e-3,1,1, 0e-3,1,1]; % Vsh, Vsc, tc
save(act_param,'G','chan_list','chan_sc','Vhalf');

sim_param = [res,'/sim_param_',name]; 
dt_out = 5e-5; dt_sim = 2e-6; tmax = 1;
save(sim_param,'dt_out','dt_sim','tmax');

% injection current
IV_data = [res,'/IV_data_',name]; 
tinj = (0:dt_out:1)'; % same sampling as output
Iinj = 0.5e-9*( tinj>=0.2 & tinj <=0.8 );
t = tinj; Vs = tinj*nan;
save(IV_data,'tinj','Iinj','t','Vs');

% make the data
id = [res,'/IV_tar_pop2'];
pars{2} = {id,IV_data,pas_param,act_param,sim_param};    
makeCell_1act1pas(id,IV_data,pas_param,act_param,sim_param)

%% generate data_pop3 - pospischil fig5b
name = 'pop3';

% parameters
pas_param = [res,'/pas_param_',name]; 
CM = 0.01; RM = 10; RA = 10; Em = -0.070; 
[len,dia] = match(96e-6,96e-6,2,2);
save(pas_param,'CM','RM','RA','Em','len','dia');
        
act_param = [res,'/act_param_',name]; 
G = [500 50 0.7 2]; chan_list = {'Na','Kd','KM','CaL'}; Vhalf = [0 0; 0 0; 0 0; 0 0];
V_T = 10e-3; chan_sc = [V_T,1,1, V_T,1,1; V_T,1,1, V_T,1,1; 0e-3,1,1, 0e-3,1,1; 0e-3,1,1, 0e-3,1,1]; % Vsh, Vsc, tc
save(act_param,'G','chan_list','chan_sc','Vhalf');

sim_param = [res,'/sim_param_',name]; 
dt_out = 5e-5; dt_sim = 2e-6; tmax = 2.5;
save(sim_param,'dt_out','dt_sim','tmax');

% injection current
IV_data = [res,'/IV_data_',name]; 
tinj = (0:dt_out:2.5)'; % same sampling as output 
Iinj = 0.2e-9*( tinj>=0.1 & tinj <=2.4 );
t = tinj; Vs = tinj*nan;
save(IV_data,'tinj','Iinj','t','Vs');

% make the data
id = [res,'/IV_tar_pop3'];
pars{3} = {id,IV_data,pas_param,act_param,sim_param};    
makeCell_1act1pas(id,IV_data,pas_param,act_param,sim_param)

%% generate data_pop4 - pospischil fig8a
name = 'pop4';

% parameters
pas_param = [res,'/pas_param_',name]; 
CM = 0.01; RM = 10; RA = 10; Em = -0.060; 
[len,dia] = match(96e-6,96e-6,2,2);
save(pas_param,'CM','RM','RA','Em','len','dia');
        
act_param = [res,'/act_param_',name]; 
G = [500 50 0.3 4]; chan_list = {'Na','Kd','KM','CaT'}; Vhalf = [0 0; 0 0; 0 0; 0 0]; 
V_T = 5e-3; chan_sc = [V_T,1,1, V_T,1,1; V_T,1,1, V_T,1,1; 0e-3,1,1, 0e-3,1,1; 0e-3,1,1, 0e-3,1,1]; % Vsh, Vsc, tc
save(act_param,'G','chan_list','chan_sc','Vhalf');

sim_param = [res,'/sim_param_',name]; 
dt_out = 5e-5; dt_sim = 2e-6; tmax = 2; 
save(sim_param,'dt_out','dt_sim','tmax');

% injection current
IV_data = [res,'/IV_data_',name]; 
tinj = (0:dt_out:2)'; % same sampling as output
Iinj = -0.1e-9*( tinj>=0.2 & tinj <=1.2 );
t = tinj; Vs = tinj*nan;
save(IV_data,'tinj','Iinj','t','Vs');

% make the data
id = [res,'/IV_tar_pop4'];
pars{4} = {id,IV_data,pas_param,act_param,sim_param};    
makeCell_1act1pas(id,IV_data,pas_param,act_param,sim_param)

%% run all
% run_compiled('makeCell_1act1pas',pars,[pwd,'/',cpath],mfilename,25,nan)

end
