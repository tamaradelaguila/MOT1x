%% AUXILIAR/Y TEMPORAL CODE: SELECT VISUALLY REJECTED TRIALS


nfish = 5
clearvars -except path nfish

%load data
VSDI = MOT1x('load', nfish);
VSDI.ref

% % sharks column to zeros 
for ii = 1:length(VSDI.list)
    VSDI.list(ii).shark = 0;
end

% MANUALLY INSERT SHARKS AS '1'
% return

sharks= [VSDI.list(:).shark]' ;
idx = find(sharks); 

VSDI.reject.visual = idx;

MOT1x('save', VSDI)


% Created: 09/02/22
% Last Update: 