% Compile C++ wraps

cfiles = dir('c_wrap/*.c');
 for n = 1:6
     mex(['c_wrap/' cfiles(n).name]);
 end