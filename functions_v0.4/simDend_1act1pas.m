function simDend_1act1pas(id, t,Vs, CM,RM,RA,Em,len,dia, dir_sim,dir_model)

% ensure names of appropriate format for genesis
wdir = cd; cd ~; hdir = cd; cd(wdir); 
if all(~strcmp(dir_sim(1),{'/','~'})); dir_sim = [wdir,'/',dir_sim]; end
if strcmp(dir_sim(1),'~'); dir_sim = [hdir,dir_sim(2:end)]; end
if all(~strcmp(dir_model(1),{'/','~'})); dir_model = [wdir,'/',dir_model]; end
if strcmp(dir_model(1),'~'); dir_model = [hdir,dir_model(2:end)]; end

% save voltage
if ~isdir(dir_sim); mkdir(dir_sim); end; cd(dir_sim);
if ~isdir([dir_sim,'/voltage']); mkdir([dir_sim,'/voltage']); end
for j = 1:size(Vs,2)
    file_voltage{j} = [dir_sim,'/voltage/voltage',num2str(j),'.dat ']; 
    tV = [t,Vs(:,j)]; save(file_voltage{j}(1:end-1),'tV','-ascii'); 
end

%% write passive parameters to genesis file

fid = fopen('runSim.g','w');

fprintf(fid,['float CM0=',num2str(CM),'\n']);
fprintf(fid,['float RM0=',num2str(RM),'\n']);
fprintf(fid,['float RA0=',num2str(RA),'\n']);
fprintf(fid,['float Em0=',num2str(Em),'\n']);
fprintf(fid,['float len=',num2str(len(1)),', dia=',num2str(dia(1)),'\n']);
fprintf(fid,['float len1=',num2str(len(2)),', dia1=',num2str(dia(2)),'\n']);

fprintf(fid,'\n');
fprintf(fid,['str files_voltage="',file_voltage{:},'"\n']);
fprintf(fid,['str dir_out="',dir_sim,'"\n']);
fprintf(fid,['include ',dir_model,'/simDend_1act1pas.g\n']);
fclose(fid);

%% run genesis 

[s,d] = system('genesis -nox -notty -batch runSim.g > dump.txt');
cd(wdir)

% report on setting
disp('simDend:');
disp(['dir_sim = "',dir_sim,'"']);
disp(['dir_model = "',dir_model,'"']);
disp(' ')

%% HACK - delete final line of data_Vd (genesis IO problem)

fid = fopen([dir_sim,'/data_Vd.dat'],'r+');
fseek(fid,-1000,'eof'); i = find(fread(fid,1000)==10,1,'last');
fseek(fid,i-1000,'eof'); fprintf(fid,repmat(' ',[1000-i 1]));
fclose(fid);

end
