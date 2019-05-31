%% ==============================
% load simulated Xk Yk parameters
%================================
function [t,X_k,Y_k,E_k,Gbar_k,p_k,q_k,chan] = load_XYk(dir_output,rt)

% read Ik simulation data 
data_Xk = load([dir_output,'/data_Xk.dat']);
data_Yk = load([dir_output,'/data_Yk.dat']);
nchan = size(data_Xk,2)-1; rchan = 1:nchan;

% read channel parameters
[ignore chan ignore E_k ignore Gbar_k ignore p_k ignore q_k] =...    
    textread([dir_output,'/data_Xk.dat',file_k],'%s %s %s %f %s %f %s %f %s %f',nchan); 

% extract data (vector format)
t1 = data_Xk(rt,1); Xchan1 = data_Xk(rt,1+rchan); clear data_Xk;
t1 = data_Yk(rt,1); Ychan1 = data_Yk(rt,1+rchan); clear data_Yk;

% change data to array format (recogise cols from diff(t)<0)
n = [1; find(diff(t1)<0)+1; length(t1)+1]; 
nt = min(diff(n))-1; t = t1(1:nt); clear t1; % be careful with nt here - can give error
nsim = length(n)-1; 

Xchan = zeros(nt,nsim,nchan);
Ychan = zeros(nt,nsim,nchan);
for j= 1:nsim
    X_k(:,j,:) = Xchan1(n(j):n(j)+nt-1,:);
    Y_k(:,j,:) = Ychan1(n(j):n(j)+nt-1,:);
end
clear Xchan1 Ychan1;

end
