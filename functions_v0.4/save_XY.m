%% ============================
% save XY kinetics
%==============================
function save_XY(id,dir_output)

% make useable for single/multiple outputs
if ~iscell(dir_output), dir_output = {dir_output}; end
ndir = length(dir_output); rdir = 1:ndir;

% read XY data in A, B format
data_XY = []; 
for i = rdir; data_XY = [data_XY; load([dir_output{i},'/data_XY.dat'])]; end

% extract
V = data_XY(:,1); 
tau_X = 1./data_XY(:,3); tau_Y = 1./data_XY(:,5);
X_inf = data_XY(:,2)./data_XY(:,3); Y_inf = data_XY(:,4)./data_XY(:,5);

% individual channels
n = [1; 1+find(diff(V)<0); length(V)+1]; 
nchan = length(n)-1; rchan = 1:nchan;
for k = rchan   
    rV = n(k):n(k+1)-1;
    tauX{k} = tau_X(rV); tauY{k} = tau_Y(rV);
    Xinf{k} = X_inf(rV); Yinf{k} = Y_inf(rV);
    Vk{k} = V(rV);
end

% channel props (single/multiple outputs)
if ndir==1
    [ig chan ig ig ig ig ig mpower ig npower] = ...
        textread([dir_output{1},'/data_XY.dat'],'%s%s%s%s%s%s%s%n%s%n',nchan);
else for i = rdir
    [ig chan{i} ig ig ig ig ig mpower(i) ig npower(i)] = ...
        textread([dir_output{i},'/data_XY.dat'],'%s%s%s%s%s%s%s%n%s%n',1); 
    end
end
if iscell(chan{1}); for k = rchan; chan{k} = chan{k}{1}; end; end
for k = rchan; chan{k}(1:end+1-strfind(chan{k}(end:-1:1),'/')) = []; end

save(id,'Vk','tauX','tauY','Xinf','Yinf','chan','-append');
disp('option: save XY');

end