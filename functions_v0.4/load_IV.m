%% ============================
% load simulated IV parameters
%==============================
function [t,Vm,Iinj,len,dia,link] = load_IV(dir_output)

%% read VI simulation data 
data_VI = load([dir_output,'/data_IV.dat']);
ncpt = size(data_VI,2)-2; rcpt = 1:ncpt;

% extract data (vector format)
t1 = data_VI(:,1);
Iinj1 = data_VI(:,2);
Vm1 = data_VI(:,2+rcpt);

% change data to array format (recogise cols from t==0)
n = [find(t1==0); length(t1)+1]; 
nt = min(diff(n))-1; t = t1(1:nt); 
nsim = length(n)-1; 

Iinj = nan*zeros(nt,nsim); Vm = nan*zeros(nt,nsim,ncpt);
for j= 1:nsim
    Iinj(:,j) = Iinj1(n(j):n(j)+nt-1);
    Vm(:,j,:) = Vm1(n(j):n(j)+nt-1,rcpt);
end

%% read parameters
npar = 6+ncpt; rpar = npar*(rcpt-1);
[ignore object par val] = textread([dir_output,'/data_IV.dat'],'%s%s%s%f',npar*ncpt);
len = val(rpar+5); dia = val(rpar+6);
link = nan*zeros(ncpt); for i = 1:ncpt; link(i,:) = val(rpar+6+i); end

end