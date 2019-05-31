%% ============================
% load simulated Vdend parameters
%==============================
function [t,Vd] = load_Vd(dir_output,rt)

%% read Vdend simulation data 
data_Vdend = load([dir_output,'/data_Vd.dat']);

% extract data (vector format)
t1 = data_Vdend(rt,1);
Vd1 = data_Vdend(rt,2);

% change data to array format (recogise cols from diff(t)<0)
n = [1; find(diff(t1)<0)+1; length(t1)+1]; 
nt = min(diff(n))-1; t = t1(1:nt); clear t1; % be careful with nt here - can give error
nsim = length(n)-1; 

Vd = nan*zeros(nt,nsim);
for j= 1:nsim
    Vd(:,j) = Vd1(n(j):n(j)+nt-1);
end
 
% %% read parameters
% npar = 6+ncpt; rpar = npar*(rcpt-1);
% [ignore object par val] = textread([dir_output,file_VI],'%s %s %s %f',npar*ncpt);
% len = val(rpar+5); dia = val(rpar+6);
% link = nan*zeros(ncpt); for i = 1:ncpt; link(i,:) = val(rpar+6+i); end

end
