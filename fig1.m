function fig1
% example fits: 1 active 1 passive compartment

clear all; dbstop if error; clc;
fpath = 'functions_v0.4'; path(path,fpath); 
% cpath = '../compiled_v0.4'; path(path,cpath);
res = [pwd,'/',mfilename,'_res']; if ~isdir(res); mkdir(res); end
% if isdir('/output'); rmdir('/output','s'); end; mkdir('/output');

% data to fit
name = {'pop1','pop2','pop3','pop4'}; 
ncell = length(name); rcell = 1:ncell;

i = 1;
for l = rcell
    IV_tar{l} = [pwd,'/fig1_tar/IV_tar_',name{l}]; % for phase plane error
    pas_param{l} = [pwd,'/fig1_tar/pas_param_',name{l}];
    act_props{l} = [pwd,'/fig1_tar/act_param_',name{l}];
    sim_param{l} = [pwd,'/fig1_tar/sim_param_',name{l}];
    act_param{l} = [res,'/act_param_',name{l}];
    IV_fit{l} = [res,'/IV_fit_',name{l}];
    
    fit_param{l} = [res,'/fit_param_',name{l}];
    load(sim_param{l},'dt_sim'); save(fit_param{l},'dt_sim');

    fitCell_1act1pas(act_param{l},IV_tar{l},pas_param{l},act_props{l},fit_param{l}); 
    makeCell_1act1pas(IV_fit{l},IV_tar{l},pas_param{l},act_param{l},sim_param{l}); 
    
%     pars1{i} = {act_param{l},IV_tar{l},pas_param{l},act_props{l},fit_param{l}};    
%     pars2{i} = {IV_fit{l},IV_tar{l},pas_param{l},act_param{l},sim_param{l}};  
%     i = i + 1;
end

% run_compiled('fitCell_1act1pas',pars1,[pwd,'/',cpath],[mfilename,'_1'],13,nan)
% i = 1; while i>0; [a,b] = system('qstat'); i = length(findstr(b,mfilename)); pause(15); end; pause(15);
% run_compiled('makeCell_1act1pas',pars2,[pwd,'/',cpath],[mfilename,'_2'],13,nan)
% i = 1; while i>0; [a,b] = system('qstat'); i = length(findstr(b,mfilename)); pause(15); end; pause(15);

%% analyse results

for k = rcell
    % php error
    load(IV_tar{k}); V_tar = Vs; 
    load(IV_fit{k}); V_fit = Vs;
    e_php(k,:) = sqrt( e2_php(t,V_tar,V_fit,20) );
    
    % res and gmax error
    load(act_props{k}); G_tar = G;
    load(act_param{k}); G_fit = G; e_res(k) = sqrt(e2);            
    e_G(k,1) = sqrt( mean(( G_fit - G_tar ).^2 ./ G_tar.^2 ) );
    e_G(k,2) = mean( abs( G_fit - G_tar )./G_tar );

    % store voltage traces
    load(IV_tar{k},'t','Vs'); t_tar{k} = t; Vs_tar{k} = Vs;
    load(IV_fit{k},'t','Vs'); t_fit{k} = t; Vs_fit{k} = Vs;
end

save fig1_res
clear all
load fig1_res

%% plot fits
tlab = {'FS','RS','IB','LTS'};
xpos = [0.07 0.32 0.57 0.82]; ypos = [0.59,0.09];

figure(1); clf
let = {'\bf A','\bf B','\bf C','\bf D','\bf E','\bf F','\bf G','\bf H'};
tmax = [0.5 1 2.5 2];

for k = rcell
    subplot(2,4,k); hold on; box; grid;
    plot(t_tar{k},1e3*Vs_tar{k},'k')
    title([tlab{k},': Target'],'Fontsize',10); axis([0 tmax(k) -100 100]);
    xlabel('time (sec)','Fontsize',8); ylabel('membrane potential (mV)','Fontsize',8);
    set(gca,'XTick',[0:4]*tmax(k)/4); set(gca,'YTick',[-100:50:100]); set(gca,'Fontsize',8);
    text(-0.4,1.09,let{k},'units','normalized','Fontsize',12);
    set(gca,'position',[xpos(k) ypos(1) 0.17 0.36],'units','normalized');

    subplot(2,4,4+k); hold on; box; grid;
    plot(t_fit{k},1e3*Vs_fit{k},'k'); 
    title([tlab{k},': Fit'],'Fontsize',10); axis([0 tmax(k) -100 100]);
    xlabel('time (sec)','Fontsize',8); ylabel('membrane potential (mV)','Fontsize',8);
    set(gca,'XTick',[0:4]*tmax(k)/4); set(gca,'YTick',[-100:50:100]); set(gca,'Fontsize',8);
    text(0.025,0.80,['e_{php}=',num2str(e_php(k,2),'%5.2f')],'Units','Normalized','Fontsize',8); 
    text(0.025,0.90,['e_{res}=',num2str(e_res(k),'%5.2f')],'Units','Normalized','Fontsize',8);
    text(-0.4,1.09,let{4+k},'units','normalized','Fontsize',12);
    set(gca,'position',[xpos(k) ypos(2) 0.17 0.36],'units','normalized');
end
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 7 4]);
print('-r300','-djpeg',mfilename) 

end

%% ==================================
% phase plane histogram error
%====================================
function e2 = e2_php(t,Vm1,Vm2,nbins)

nsim = size(Vm1,2); nbins = nbins + 1;
nt = min(length(Vm1),length(Vm2));
Vm1 = Vm1(1:nt); Vm2 = Vm2(1:nt);

% calculate Vmdot   
dt = t(2)-t(1);
Vm1dot = diff(Vm1)/dt; Vm1dot = [Vm1dot; Vm1dot(end,:)];
Vm2dot = diff(Vm2)/dt; Vm2dot = [Vm2dot; Vm2dot(end,:)];

% bin boundaries (defined from Vm1 - set as target)
lVm = min(Vm1); mVm = max(Vm1); dVm = mVm - lVm;
lVmdot = min(Vm1dot); mVmdot = max(Vm1dot); dVmdot = mVmdot - lVmdot;
rVm = linspace(lVm-0.5*dVm/nbins,mVm+0.5*dVm/nbins,nbins); 
rVmdot = linspace(lVmdot-0.5*dVmdot/nbins,mVmdot+0.5*dVm/nbins,nbins);

% find 1D histograms
[hVm1,bVm1] = histc(Vm1,rVm);
[hVm2,bVm2] = histc(Vm2,rVm);
[hVm1dot,bVm1dot] = histc(Vm1dot,rVmdot);
[hVm2dot,bVm2dot] = histc(Vm2dot,rVmdot);

% find 2D histograms
hVmVmdot1 = histc(bVm1dot+nbins*bVm1,1:nbins^2); hVmVmdot1 = hVmVmdot1/sum(hVmVmdot1);
hVmVmdot2 = histc(bVm2dot+nbins*bVm2,1:nbins^2); hVmVmdot2 = hVmVmdot2/sum(hVmVmdot2);

% find error from 2D hist
e2 = [ sum( (hVmVmdot1-hVmVmdot2).^2 ),...
        sum(sqrt(abs(hVmVmdot1-hVmVmdot2)))^4/sum(sqrt(abs(hVmVmdot1)))^4];

end