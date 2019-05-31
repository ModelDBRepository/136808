%% ============================
% load simulated Ak parameters
%==============================
function [t,A_k,E_k,Gbar_k,p_k,q_k,chan] = load_Ak(dir_output,rt)

% read Ik simulation data 
file_Ik = 'data_Ik.dat';
data_Ik = load([dir_output,'/',file_Ik]);
nchan = size(data_Ik,2)-1; rchan = 1:nchan;

% read channel parameters
[ignore chan ignore E_k ignore Gbar_k ignore p_k ignore q_k] =...    
    textread([dir_output,'/',file_Ik],'%s %s %s %f %s %f %s %f %s %f',nchan); 

% extract data (vector format)
t1 = data_Ik(rt,1); Ichan1 = data_Ik(rt,1+rchan); clear data_Ik;

% change data to array format (recogise cols from diff(t)<0)
n = [1; find(diff(t1)<0)+1; length(t1)+1]; 
nt = min(diff(n))-1; t = t1(1:nt); clear t1; % be careful with nt here - can give error
nsim = length(n)-1; 

Ichan = zeros(nt,nsim,nchan);
for j= 1:nsim
    Ichan(:,j,:) = Ichan1(n(j):n(j)+nt-1,:);
end
clear Ichan1;

for l = 1:nchan; A_k(:,:,l) = Ichan(:,:,l)/Gbar_k(rchan(l)); end 

end
