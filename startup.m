toolbox_unc = 'L:\MLCV\';
folder_name = 'stprtool';
dest_path = 'C:\temp';

[status, cmd_out] = system(sprintf('compile_sprt.bat "%s\\%s" "%s\\%s"', toolbox_unc, folder_name, dest_path, folder_name));
if (status~= 0)
    display 'File copy failed. See cmd_out variable for details.'
else
    addpath(sprintf('%s\\%s',dest_path, folder_name));
    stprpath(sprintf('%s\\%s',dest_path, folder_name));
    compilemex(sprintf('%s\\%s', dest_path, folder_name));
    clear all;
end

%%%

set(0,'defaulttextinterpreter','latex')
