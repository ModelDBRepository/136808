%% ============================
% plot I and V traces
%==============================
function plot_IV(id,dir_output,varargin)

if nargin==3
    IV_data = varargin{1};
    load(IV_data,'tinj','Iinj','t','Vs');
    Iinj = Iinj(1:length(tinj));
else
    tinj = nan; Iinj = nan; t = nan; Vs = nan;
end

% make useable for single/multiple outputs
if ~iscell(dir_output), dir_output = {dir_output}; end
ndir = length(dir_output); rdir = 1:ndir;

% read IV data
data_IV = []; 
for i = rdir
    data_IV = [data_IV; load([dir_output{i},'/data_IV.dat'])];
end

% extract
t_sim = data_IV(:,1); Iinj_sim = data_IV(:,2); Vs_sim = data_IV(:,3);

% name of sim
dataset = id; dataset(1:end+1-strfind(dataset(end:-1:1),'/')) = [];

% plot
figure(1); clf
subplot(1,2,1); hold on; box  on; grid on;
plot(t,1e3*Vs,'b', t_sim,1e3*Vs_sim,'r')
title({texlabel(['sim result: ',dataset],'literal')})
xlabel('time (sec)','Fontsize',8); ylabel('voltage (mV)','Fontsize',8);
ax = axis; axis([0 max(t_sim) ax(3) ax(4)]);
subplot(1,2,2); hold on; box on; grid on;
plot(tinj,1e9*Iinj,'b', t_sim,1e9*Iinj_sim,'r')
xlabel('time (sec)','Fontsize',8); ylabel('current (nA)','Fontsize',8);
ax = axis; axis([0 max(t_sim) ax(3) ax(4)]);

% print figure
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 6]);
% saveas(gcf,[id,'_IV']);
print('-r300','-djpeg',[id,'_IV']);
% close all

% message
disp(['option: plot IV: ',id,'_IV','.jpg']);
if nargin==3; disp(['data file = "',IV_data,'"']); end

end
