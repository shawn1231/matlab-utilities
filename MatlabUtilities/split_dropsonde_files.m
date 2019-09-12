% This file is used to split the dropsonde log files into parts, the
% Columbus V900 records all GPS tracks in a single file unless it is
% stopped and restarted in a very specific way, thus this script allows the
% algorithmic separation of individual GPS tracks from a single long file,
% this file is copied in this directly because it contains a number of data
% reduction strategies which may be useful in other scripts, specifically
% the use of ginput and the subsequent determination of min and max indices
% which are then used to trim the data

close all
clear

dirData = dir('*.csv');

ds = {};

for i = 1:1:length(dirData)
    
    df = readtable(dirData(i).name);
    
    dummy_index = 1:1:length(df.HEIGHT);
    
    plot(df.HEIGHT);
    [x, ~] = ginput;
    close
    
    fname = dirData(i).name;
    fname = fname(1:(end-4));
    fname = strcat(fname,'.mat');
    
    for j = 1:1:length(x')
        
        nfirst = floor(x(j)-100);
        nlast  = ceil(x(j)+250);
        
        [maxalt idx_maxalt] = max(df.HEIGHT(nfirst:nlast));

        idx_maxalt = idx_maxalt + nfirst;
        
        for jj = idx_maxalt:1:nlast
            if(df.HEIGHT(jj) > maxalt*.98)
                idx_maxalt = jj;
            end
        end

        gl = mode(df.HEIGHT(idx_maxalt:nlast));
        for jj = nlast:-1:idx_maxalt
            if(df.HEIGHT(jj) < gl*1.02)
                idx_minalt = jj;
            end
        end

        ds{1,j} = df(idx_maxalt:idx_minalt,:);
        ds{2,j} = df{idx_maxalt,4};
        ds{3,j} = df{idx_maxalt,5};
    
        save(fname, 'ds');
        
        figure;
        plot(ds{1,j}.HEIGHT);
        
    end
end

% figure;
% plot(ds{1,1}.HEIGHT)
% 
% [b a] = butter(2,.05/(1/2));
% 
% heightf = filter(b,a,df.HEIGHT);
% 
% figure;
% plot(heightf(nfirst:nlast));
% hold on
% plot(df.HEIGHT(nfirst:nlast));
% yyaxis right
% heightdif = diff(heightf);
% plot(heightdif(nfirst:nlast))
% heightdif_f = filter(b,a,heightdif);
% plot(heightdif_f(nfirst:nlast))
% nz = (heightdif < .5 & heightdif > -.5);
% plot(nz(nfirst:nlast),'k')

        
        