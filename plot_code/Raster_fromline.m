% %% LOAD / COMPUTE SETTINGS
% 
%     
% clearvars -except nfish
% W = pwd;
% cd 'C:\Users\User\Documents\MatLab\MOT1x'
% user_settings
% cd(W)
% 
% pathlines = 'C:\Users\User\Documents\MatLab\MOT1x\plot\raster_fromline';
% load(pathlines)
% 
% nfish = 1;
%     VSDI = MOT1x('load',nfish);
%     im = VSDI.backgr(:,:,VSDI.nonanidx(1)); axis image
%    imagesc(im);
%     roiline = drawline();
%         
%     % GET COORD
%     linecoord(nfish).x = [roiline.Position(1,1) roiline.Position(2,1)]; %x values
%     linecoord(nfish).y = [roiline.Position(1,2) roiline.Position(2,2)]; %y values
%     
% 
% % save(pathlines, 'linecoord')
%%
%----------------------------------------------------------------
% @SET: fish + conditions
%----------------------------------------------------------------
pathlines = 'C:\Users\User\Documents\MatLab\MOT1x\plot\raster_fromline';

load(pathlines)

saveraster = 1;
savein = 'C:\Users\User\Documents\MatLab\MOT1x\plot\raster_fromline';


for  nfish = [1 5]
   clearvars -except nfish path linecoord saveraster  savein
 

cond_codes = [1:3];

movie_ref = '_04filt1'; %
%----------------------------------------------------------------
% @SET: MEASURE (OR LOOP THROUGH ALL MEASURES)
%----------------------------------------------------------------
reject_on= 1;

setting.manual_visual = 1; %
% setting.manual_reject = 0; %
% setting.GSmethod_reject = 0;  %
% setting.GSabsthres_reject = 0; %
% setting.force_include = 0; %

%% LOAD / COMPUTE SETTINGS
%----------------------------------------------------------------
% LOAD DATA
%----------------------------------------------------------------
VSDI = MOT1x('load', nfish);
VSDmov = MOT1x('loadmovie',nfish,movie_ref);

%----------------------------------------------------------------
% COMPUTE REJECTION IDX FROM REJECT-OPTIONS
%----------------------------------------------------------------
rej = 'reject' ;
if reject_on > 1
rej = [rej num2str(reject_on)];
end

rejectidx = [];

if setting.manual_visual
    rejectidx = [rejectidx  makeRow(VSDI.(rej).visual)];
end


rejectidx = sort(unique(rejectidx));


%----------------------------------------------------------------
%% CODE: TILES + WAVEs (all roi for each condition)
%----------------------------------------------------------------
% cond_codes = [201];
% fact_thresh =0.4; % @SET : limits parameters
fact_thresh =0.7; % @SET : limits parameters
fact_clim= 1.5;

for condi = makeRow(cond_codes)
    %----------------------------------------------------------------
    %
    %----------------------------------------------------------------
    [sel_trials] = find(VSDI.condition(:,1)==condi);
    
    if reject_on
        sel_trials = setdiff(sel_trials, rejectidx);
    end
    
    %to plot single trial
    movie2plot = mean(VSDmov.data(:,:,1:end-1,sel_trials),4);
    back = mean(VSDmov.data(:,:,end,sel_trials),4);
    

    % GET COORD FROM SAVED STRUCTURE
    xs = linecoord(nfish).x;
    ys = linecoord(nfish).y;
    
    F0val = improfile(back, xs, ys);

    % GET (%F0) PIXEL VALUES FOR EACH TIMEPOINT AND STORE IN RASTER
    
    for ti = 1:length(VSDI.timebase)
        im = movie2plot(:,:,ti);
        pixval = improfile(im, xs, ys);
        raster(:,ti) = pixval./F0val;
        clear im
    end
    
    figure
    % plot(pixval, 1:length(pixval)); axis tight; title('pixel values')
    ax1= subplot(1,2,1);
    imagesc(raster);
    colormap(ax1, parula)
    colorbar;
    
    ylabel('mediolateral pixels')
    xlabel('frames from S onset')
        title('raster of activity')

    
    ax2= subplot(1,2,2);
    
    coord = [xs(1) ys(1); xs(2) ys(2)];
    im = VSDI.backgr(:,:,VSDI.nonanidx(1));
%     im = imrotate(im,90)
    imagesc(im);
    axis image
    ax2 = gca ;
    colormap(ax2, 'bone')
    drawline(ax2, 'Position', coord, 'Color', [0 0 0])
    ylabel('rostrocausal axis')
    xlabel('mediolateral axis')

%     axis image;
    title('reference line')
    
        
        
        sgtitle([num2str(VSDI.ref), movie_ref, 'rej', num2str(reject_on), VSDI.conditionlabels{condi+1,2}, VSDI.info.Sside])
        
        savename= ['RASTERLINE' num2str(VSDI.ref) movie_ref VSDI.conditionlabels{condi+1,2} VSDI.info.Sside '_rej'  num2str(reject_on)];
        
        if saveraster
            saveas(gcf, fullfile(savein, [savename '.jpg']), 'jpg')
            
%             set(gcf,'units','normalized','outerposition',[0 0 1 1]) %set in total screen
%             print(fullfile(savein, [savename '.svg']),'-r600','-dsvg', '-painters') % prints it as you see them %STILL TO TEST!

            close all
        end
        
        
end %condi
end
blob()
blob() ; pause(0.2) ; blob()


% newsave = '/home/tamara/Documents/MATLAB/VSDI/MOT1x/plot/informes_code/03_figure_sketch/def_figs/tiles';
% saveas(gcf, fullfile(newsave,savename) 'jpg')

%-----------------------------------------------------------------
% PRINT INCLUDED AND EXCLUDED TRIALS
% ----------------------------------------------------------------
%
% for condi = cond_codes
%
%     [sel_trials] = find(VSDI.condition(:,1)==condi);
%     local_reject = intersect(sel_trials, rejectidx);%just to display later;
%     sel_trials = setdiff(sel_trials, rejectidx);
%
%     disp(['Included trials for condition' num2str(condi) ':' ])
%     disp(sel_trials)
%     disp('%')
%     disp(['Rejected trials for condition' num2str(condi) ':'])
%     disp(local_reject)
% end


% Created: 10/02/22
% source: /home/tamara/Documents/MATLAB/VSDI/TORus/plot_code/informes_code/03_figure_sketch/plot_tiles_and_waves.m
% Last update: 