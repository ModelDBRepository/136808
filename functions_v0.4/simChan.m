function simChan(id, t,Vs, chan,chan_sc,Vhalf, dir_sim,dir_model)

% ensure names of appropriate format for genesis
wdir = cd; cd ~; hdir = cd; cd(wdir); 
if all(~strcmp(dir_sim(1),{'/','~'})); dir_sim = [wdir,'/',dir_sim]; end
if strcmp(dir_sim(1),'~'); dir_sim = [hdir,dir_sim(2:end)]; end

if all(~strcmp(dir_model(1),{'/','~'})); dir_model = [wdir,'/',dir_model]; end
if strcmp(dir_model(1),'~'); dir_model = [hdir,dir_model(2:end)]; end

if ~iscell(chan); chan = {chan}; end; nchan = length(chan); rchan = 1:nchan;
for k = rchan; if all(~strcmp(chan{k}(1),{'/','~'})); chan{k} = [wdir,'/',chan{k}]; end; end
for k = rchan; if strcmp(chan{k}(1),'~'); chan{k} = [hdir,chan{k}(2:end)]; end; end

% save voltage
if ~isdir(dir_sim); mkdir(dir_sim); end; cd(dir_sim);
if ~isdir([dir_sim,'/voltage']); mkdir([dir_sim,'/voltage']); end
for j = 1:size(Vs,2)
    file_voltage{j} = [dir_sim,'/voltage/voltage',num2str(j),'.dat ']; 
    tV = [t,Vs(:,j)]; save(file_voltage{j}(1:end-1),'tV','-ascii'); 
end

% channels
if ~iscell(chan); chan = {chan}; end; nchan = length(chan);

% genesis scales
v = chan_sc;
ox_Xinf = v(:,1)./v(:,2)-Vhalf(:,1).*(1-1./v(:,2)); ox_Xtau = v(:,1);
sx_Xinf = v(:,2); sx_Xtau = ones(nchan,1);
sy_Xtau = v(:,3); 
ox_Yinf = v(:,4)./v(:,5)-Vhalf(:,2).*(1-1./v(:,5)); ox_Ytau = v(:,4);
sx_Yinf = v(:,5); sx_Ytau = ones(nchan,1);
sy_Ytau = v(:,6);

%% write channels to genesis file

fid = fopen('runSim.g','w');
fprintf(fid,'str loc_chans="/channels"\n');
fprintf(fid,'create neutral {loc_chans}\n');

for i = 1:nchan
    fprintf(fid,'\n');
    fprintf(fid,'create neutral temp_chan\n');
    fprintf(fid,'pushe temp_chan\n');  
    fprintf(fid,['    str chan_dir="',fileparts(chan{i}),'" \n']);
    fprintf(fid,['    include ',chan{i},'\n']);
    fprintf(fid,['    scaletabchan {el #[CLASS=channel]} X minf ',num2str(sx_Xinf(i)),' 1 ',num2str(ox_Xinf(i)),' 0 \n']);
    fprintf(fid,['    scaletabchan {el #[CLASS=channel]} X tau ',num2str(sx_Ytau(i)),' ',num2str(sy_Xtau(i)),' ',num2str(ox_Xtau(i)),' 0 \n']);
    fprintf(fid,['    scaletabchan {el #[CLASS=channel]} Y minf ',num2str(sx_Yinf(i)),' 1 ',num2str(ox_Yinf(i)),' 0 \n']);
    fprintf(fid,['    scaletabchan {el #[CLASS=channel]} Y tau ',num2str(sx_Ytau(i)),' ',num2str(sy_Ytau(i)),' ',num2str(ox_Ytau(i)),' 0 \n']);
    fprintf(fid, '    move {el #[CLASS=channel]} {loc_chans}\n');
    fprintf(fid,'pope temp_chan\n');
end

fprintf(fid,'\n');
fprintf(fid,['str files_voltage="',file_voltage{:},'"\n']);
fprintf(fid,['str dir_out="',dir_sim,'"\n']);
fprintf(fid,['include ',dir_model,'/simChan.g\n']);
fclose(fid);

%% run genesis 

[s,d] = system('genesis -nox -notty -batch runSim.g > dump.txt');
cd(wdir)

% report on settings
disp('simChan:');
disp(['dir_sim = "',dir_sim,'"']);
disp(['dir_model = "',dir_model,'"']);
for k = rchan; disp(['channel_',num2str(k),' = "',chan{k},'"']); end
disp(' ');

%% HACK - delete final line of data_Ik (genesis IO problem)

% fid = fopen([dir_sim,'/data_Ik.dat'],'r+');
% fseek(fid,-1000,'eof'); i = find(fread(fid,1000)==10,1,'last');
% fseek(fid,i-1000,'eof'); fprintf(fid,repmat(' ',[1000-i 1]));
% fclose(fid);

end