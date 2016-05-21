% APE May 25, 2016

% This function allows to run idTracker from command line, even with
% the compiled version. To use it, first create a "datosegm" file by
% opening idTracker, setting the parameters and clicking "S&E". Then, go to
% Windows command window and type "idTracker path_to_datosegm", where
% path_to_datosegm is the full path to the datosegm.mat file created
% before.

function idTracker_batch(path_to_datosegm)

load(path_to_datosegm)
datosegm=variable;
idTracker(datosegm)