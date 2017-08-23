function filename=path2matname(path)
datacfg
start=length(root);
shortpath=path(start+2:end);
filename=strrep(shortpath,'\','-');
filename=strrep(filename,'/','-');
filename=[filename,'.mat'];