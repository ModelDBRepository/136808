%% ============================
% plot XY kinetics 
%==============================
function plot_XY(id,dir_output)

% make useable for single/multiple outputs
if ~iscell(dir_output), dir_output = {dir_output}; end
ndir = length(dir_output); rdir = 1:ndir;

% read XY data in A, B format
data_XY = []; 
for i = rdir
    data_XY = [data_XY; load([dir_output{i},'/data_XY.dat'])];
end

% extract
V = data_XY(:,1); 
tau_X = 1./data_XY(:,3); tau_Y = 1./data_XY(:,5);
X_inf = data_XY(:,2)./data_XY(:,3); Y_inf = data_XY(:,4)./data_XY(:,5);

% individual channels
n = [1; 1+find(diff(V)<0); length(V)+1]; nchan = length(n)-1; rchan = 1:nchan;

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

% plot results
figure(2); clf
for k = rchan
    
    % channel properties
    rV = n(k):n(k+1)-1;
    [ig,iXhalf] = min(abs(X_inf(rV)-0.5)); iXhalf = n(k) + iXhalf - 1; 
    [ig,iYhalf] = min(abs(Y_inf(rV)-0.5)); iYhalf = n(k) + iYhalf - 1;  
    if iXhalf==1; iXhalf = 6; end, if iYhalf==1; iYhalf = 6; end % hack if no gate 
    [mtauX,itauX] = max(tau_X(rV)); itauX = n(k) + itauX - 1; 
    [mtauY,itauY] = max(tau_Y(rV)); itauY = n(k) + itauY - 1;
    dXdV = diff(X_inf)./diff(V); dXdVhalf = mean(dXdV(iXhalf+[-5:5])); % scaletabchan issue
    tangX = dXdVhalf*(V(rV)-V(iXhalf)) + 0.5; kX = 0.25/dXdVhalf;
    dYdV = diff(Y_inf)./diff(V); dYdVhalf = mean(dYdV(iYhalf+[-5:5])); % scaletabchan issue
    tangY = dYdVhalf*(V(rV)-V(iYhalf)) + 0.5; kY = 0.25/dYdVhalf;
    
    % plots
    subplot(2,nchan,k); hold on; grid; box;
    plot(1e3*V(rV),X_inf(rV).^mpower(k).*Y_inf(rV).^npower(k),'k', 'LineWidth',2)
    plot(1e3*V(rV),X_inf(rV),'g', 1e3*V(iXhalf)*[1,1],[0,1.1],'--g',...
        1e3*V(rV),Y_inf(rV),'r', 1e3*V(iYhalf)*[1,1],[0,1.1],'--r', 'LineWidth',2)
    plot(1e3*V(rV),tangX,'--g', 1e3*V(rV),tangY,'--r', 'LineWidth',1)
    axis([-100,50,0,1.1]); title([texlabel(chan{k},'literal'),...
        ' (p,q=',num2str([mpower(k) npower(k)],'%3.0f'),')'],'Fontsize',8);  
    if k==1; ylabel('{\color{green} X_{\infty}}, {\color{red} Y_{\infty}}, {\color{black} X_{\infty}^pY^q_{\infty}}','Fontsize',8); end
    
    subplot(2,nchan,k+nchan); hold on; grid; box;
    plot(1e3*V(rV),1e3*tau_X(rV),'g', 1e3*V(itauX)*[1,1],[0,1e6],'--g',... 
        1e3*V(rV),1e3*tau_Y(rV),'r', 1e3*V(itauY)*[1,1],[0,1e6],'--r', 'LineWidth',2);
    title({['{\color{green}X_{1/2}}=',num2str(1e3*V(iXhalf),'%3.0f'),' {\color{red}Y_{1/2}}=',num2str(1e3*V(iYhalf),'%3.0f'),...
        ' {\color{green}k_X}=',num2str(1e3*kX,'%3.0f'),' {\color{red}k_Y}=',num2str(1e3*kY,'%3.0f')],...
        ['{\color{green}V_X}=',num2str(1e3*V(itauX),'%3.0f'),' {\color{red}V_Y}=',num2str(1e3*V(itauY),'%3.0f'),...
        '  {\color{green}\tau_X}=',num2str(1e3*mtauX,'%3.1f'),' {\color{red}\tau_Y}=',num2str(1e3*mtauY,'%3.1f')]},'Fontsize',8,'FontWeight','bold');
    axis([-100,50,-1e-10,1.1*1e3*max([mtauX mtauY])]); 
    if k==1; ylabel('{\color{green} \tau_X}, {\color{red} \tau_Y} (msec)','Fontsize',8); end        
end

% output plot
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 8]);
% saveas(gcf,[id,'_XY'])
print('-r300','-djpeg',[id,'_XY']);
% close all

% message
disp(['option: plot XY: ',id,'_XY','.jpg']);

end
