figs = dir(fullfile(pwd, '*.fig'));

for i=1:size(figs,1)
    name = figs(i).name;
    handle = openfig(name);
    newname = strsplit(name, '.');
    newname = strcat(newname(1), '.tikz');
    newname = strjoin(newname, '');
    matlab2tikz(newname, 'figurehandle', handle)
end