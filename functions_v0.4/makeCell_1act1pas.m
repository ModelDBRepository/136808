% notes: code modified because of passive fit work;
%        need to run again for active fitting (when revise ms)
%        changes: no dir_sim, corrected tinj error, optional act_param args
%        also to using t as a variable - written out (to check)

function makeCell_1act1pas(id,IV_data,pas_param,act_param,sim_param)

% OPTIONS: plot_XY, plot_IV, save_XY, test

output = []; % output string
diary([id,'.txt'])
disp(' '); disp(['running makeCell_1act1pas at ',date]); disp(' ')
output = [output,id,'.txt, '];

%% load data from file

warning off MATLAB:load:variableNotFound
disp(['loading ',IV_data,'.mat'])
load(IV_data,'tinj','Iinj');
disp(['loading ',pas_param,'.mat'])
load(pas_param,'CM','RM','RA','Em','len','dia');
disp(['loading ',act_param,'.mat'])
load(act_param,'G','chan_list','chan_sc','Vhalf');
disp(['loading ',sim_param,'.mat'])
load(sim_param,'dt_out','dt_sim','tmax','dir_sim','dir_model','option');

% optional arguments
if ~exist('option','var'); option = ''; end
[id_path,id_name] = fileparts(id); 
nodir = ~exist('dir_sim','var'); if nodir; dir_sim = ['output/output_',id_name]; end
dir_model = fileparts(mfilename('fullpath')); 
if ~exist('dt_sim','var'); dt_sim = tinj(2)-tinj(1); end
if ~exist('dt_out','var'); dt_out = dt_sim; end
if ~exist('chan_sc','var'); chan_sc = []; end
if ~exist('Vhalf','var'); Vhalf = []; end
dir_chans = fileparts(mfilename('fullpath')); 

% ensure current trace starts at time zero
ntinj = size(tinj,1); t0 = tinj(1,:);
tinj = tinj - repmat(t0,[ntinj,1]); 

% truncate range
ntinj = max(find(tinj<=tmax)); rtinj = 1:ntinj; 
tinj_data = tinj(rtinj); Iinj_data = Iinj(rtinj,:); 

% ensure chan_sc and Vhalf have nchan elements
nchan = length(chan_list); nsc = size(chan_sc,1); nVh = size(Vhalf,1);
if nsc>nchan; chan_sc(nchan+1:end,:) = []; nsc = nchan; end
chan_sc = [chan_sc; repmat([0,1,1,0,1,1],[nchan-nsc,1])];
if nVh>nchan; Vhalf(nchan+1:end,:) = []; nVh = nchan; end
Vhalf = [Vhalf; repmat([0,0],[nchan-nVh,1])];
for i = 1:nchan; if isempty(fileparts(chan_list{i})); chan_list{i} = [dir_chans,'/',chan_list{i}]; end; end

%% run simulation
simCell_1act1pas(id, tinj_data,Iinj_data, CM,RM,RA,Em,len,dia, G,chan_list,chan_sc,Vhalf, dt_sim,dir_sim,dir_model);
[t_sim,Vm_sim,Iinj_sim] = load_IV(dir_sim);
Vs_sim = squeeze(Vm_sim(:,:,1)); tinj_sim = t_sim;

% correct time shift from genesis timescale 
dt_inj = tinj(2) - tinj(1); fs = ceil(dt_inj/dt_sim); 
t_sim = t_sim - (fs-1)*dt_sim; rt = t_sim>=0; tinj_sim = t_sim;
t_sim = t_sim(rt); Vs_sim = Vs_sim(rt,:); tinj_sim = tinj_sim(rt); Iinj_sim = Iinj_sim(rt,:);

% subsample results to dt_out
fs = fix(dt_out/dt_sim); rt = 1:fs:length(t_sim);
t_sim = t_sim(rt); Vs_sim = Vs_sim(rt,:); tinj_sim = tinj_sim(rt); Iinj_sim = Iinj_sim(rt,:);

%% save and clean up

tinj = tinj_sim; t = t_sim; Iinj = Iinj_sim; Vs = Vs_sim; 
save(id, 'tinj','Iinj','t','Vs')  
disp(['saving results: ',id,'.mat'])
output = [output,id,'.mat, '];

% option: plot results
if strfind(option,'plot_XY'); plot_XY(id,dir_sim); output = [output,id,'_XY.jpg, ']; end
if strfind(option,'plot_IV'); plot_IV(id,dir_sim); output = [output,id,'_IV.jpg, ']; end
if strfind(option,'save_XY'); save_XY(id,dir_chan); end

% clean up
if isempty(strfind(option,'test')); rmdir(dir_sim,'s'); end

% CARMEN output
disp(' ')
disp(['<output>',output(1:end-2),'<\output>'])
diary off

end
