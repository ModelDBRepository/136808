% maybe want some optional inputs as for makeCell routines

function fitCell_1act1pas(id,IV_data,pas_param,act_props,sim_param)

% OPTIONS: save_b, save_A, save_XY, plot_XY, test

output = []; % output string
% diary([id,'.txt'])
disp(' '); disp(['running fitCell_1act1pas at ',date]); disp(' ')
output = [output,id,'.txt, '];

%% load data from file
warning off MATLAB:load:variableNotFound
disp(['loading ',IV_data,'.mat'])
load(IV_data,'tinj','Iinj','t','Vs');
disp(['loading ',pas_param,'.mat'])
load(pas_param,'CM','RM','RA','Em','len','dia');
disp(['loading ',act_props,'.mat'])
load(act_props,'chan_list','chan_sc','Vhalf');
disp(['loading ',sim_param,'.mat'])
load(sim_param,'dt_sim','dir_sim','dir_model','option'); 

% optional arguments
if ~exist('option','var'); option = ''; end
[id_path,id_name] = fileparts(id); 
nodir = ~exist('dir_sim','var'); if nodir; dir_sim = ['output/output_',id_name]; end
dir_model = fileparts(mfilename('fullpath')); 
if ~exist('dt_sim','var'); dt_sim = tinj(2)-tinj(1); end
if ~exist('chan_sc','var'); chan_sc = []; end
if ~exist('Vhalf','var'); Vhalf = []; end
dir_chans = fileparts(mfilename('fullpath')); 

% ensure voltage trace starts at time zero
ntinj = size(tinj,1); nt = size(t,1); t0 = t(1,:);
tinj = tinj - repmat(t0,[ntinj,1]); t = t - repmat(t0,[nt,1]);

% interpolate data
t_data = t(1):dt_sim:t(end); t_data = t_data(:);
Vs_data = interp1(t,Vs,t_data,'spline'); 
Iinj_data = interp1(t,Iinj,t_data,'spline'); 
nt_data = length(t_data); nsim = size(Vs_data,2);

% ensure chan_sc and Vhalf have nchan elements
nchan = length(chan_list); nsc = size(chan_sc,1); nVh = size(Vhalf,1);
if nsc>nchan; chan_sc(nchan+1:end,:) = []; nsc = nchan; end
chan_sc = [chan_sc; repmat([0,1,1,0,1,1],[nchan-nsc,1])];
if nVh>nchan; Vhalf(nchan+1:end,:) = []; nVh = nchan; end
Vhalf = [Vhalf; repmat([0,0],[nchan-nVh,1])];
for i = 1:nchan; if isempty(fileparts(chan_list{i})); chan_list{i} = [dir_chans,'/',chan_list{i}]; end; end

%% run fitting method

% compensate for trunc in run_fit
rt = 1:nt_data-1; 

% simulate channels & load A_k (split to save memory) 
for k = 1:nchan
    for j = 1:nsim
        dir_chan{j,k} = [dir_sim,'/output_chan',num2str(k),'_sim',num2str(j)];
        simChan(id, t_data,Vs_data(:,j), chan_list{k},chan_sc(k,:),Vhalf(k,:), dir_chan{j,k},dir_model)
        [t1_data,A_k(:,j,k)] = load_Ak(dir_chan{j,k},rt);
    end
end

% simulate dendrite & load Vd
for j = 1:nsim
    dir_dend{j} = [dir_sim,'/output_dend_sim',num2str(j)];
    simDend_1act1pas(id, t_data,Vs_data(:,j), CM,RM,RA,Em,len,dia, dir_dend{j},dir_model)
    [t2_data,Vd_sim(:,j)] = load_Vd(dir_dend{j},rt); 
end

% truncate data to same size as A_k
t_data = t1_data; clear t1_data t2_data
nt_data = length(t_data); rt = rt(1:nt_data); 
Vs_data = Vs_data(rt,:); Iinj_data = Iinj_data(rt,:); 
Vd_sim = Vd_sim(rt,:);

% find b current
SA = pi*len.*dia; XA = pi*dia.^2/4; 
IC = CM*SA(1)*deriv(Vs_data,t_data,'Df1'); IC(1,:) = []; IC = [IC; IC(end,:)];
Is = (Em-Vs_data)/(RM/SA(1)); clear Vs
Id = (Vd_sim-Vs_data)/(len(2)*RA/XA(2)); clear Vd_sim
b = IC - Is - Id - Iinj_data;

% find exact solution
A1 = reshape(A_k,nt_data*nsim,nchan); 
b1 = reshape(b,nt_data*nsim,1); % clear A_k
g = pinv(A1)*b1; g = g.*(g>0); G_opt = g'/SA(1); 

% residual current error
I_res = A1*g - b1; e2_res = mean(I_res.^2)/mean(b1.^2); 

%% report, save and clean up

% message
disp(' ')
disp('results:');
disp(['G_opt = ',num2str(G_opt)]);
disp(['e^2_res = ',num2str(e2_res)]);
disp(' ')

% save active parameters (option: save_b, save_A, save_XY)
G = G_opt; e2 = e2_res; t = t_data; Ires = I_res;
save(id,'G','chan_list','chan_sc','Vhalf','e2');
disp(['saving results: ',id,'.mat'])
if strfind(option,'save_b'); save(id,'t','b','Ires','-append'); disp('option: save t b Ires'); end 
if strfind(option,'save_A'); save(id,'t','A_k','-append'); disp('option: save t A_k'); end
if strfind(option,'save_XY'); save_XY(id,dir_chan); end
output = [output,id,'.mat, '];

% option: plot channel kinetics
if strfind(option,'plot_XY'); plot_XY(id,dir_chan); output = [output,id,'_XY.jpg, ']; end

% clean up
if isempty(strfind(option,'test')); rmdir(dir_sim,'s'); end

% CARMEN output
disp(' ')
disp(['<output>',output(1:end-2),'<\output>'])
diary off

end

%% derivative function
function dVdt = deriv(V,t,method)

t = repmat(t,[1,size(V,2)]);

function d = Df(V,i); d = V(1+i:end,:)-V(1:end-i,:); d = [d; repmat(d(end,:),[i,1])]; end
function d = Db(V,i); d = V(1+i:end,:)-V(1:end-i,:); d = [repmat(d(end,:),[i,1]); d]; end
function d = Dc(V,i); d = V(1+i:end,:)-V(1:end-i,:); d = [repmat(d(end,:),[i/2,1]); d; repmat(d(end,:),[i/2,1]);]; end
  
if     strcmp(method,'Df1'); dVdt = Df(V,1)./Df(t,1); 
elseif strcmp(method,'Df2'); dVdt = 2*Df(V,1)./Df(t,1) - Df(V,2)./Df(t,2); 
elseif strcmp(method,'Db1'); dVdt = Db(V,1)./Db(t,1); 
elseif strcmp(method,'Db2'); dVdt = 2*Db(V,1)./Db(t,1) - Db(V,2)./Db(t,2); 
elseif strcmp(method,'Dc2'); dVdt = Dc(V,2)./Dc(t,2); 
elseif strcmp(method,'Dc4'); dVdt = 4/3*Dc(V,2)./Dc(t,2) - 1/3*Dc(V,4)./Dc(t,4); 
end; clear t V

end
