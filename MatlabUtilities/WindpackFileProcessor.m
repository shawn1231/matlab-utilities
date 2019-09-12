% updated to work with Eloy Windpack, previously had a logic error with
% finding max and min altitude index, it works with our GPS loggers but not
% with Eloy, this version will work with Eloy Windpack, may need
% modification for UMKC dropsonde

close all
clear

dirData = dir('*.csv');

ds = {};

%for i = 1:1:1
for i = 1:1:length(dirData)
    
    fname = dirData(i).name;

    opts = detectImportOptions(fname,'Delimiter',',');

    opts.VariableNamesLine = 1;
    opts.DataLine = 2;

    df = readtable(fname,opts,'ReadVariableNames',true);

    df.link1 = [];
    df.link2 = [];
    df.link3 = [];
    df.link4 = [];
    df.link5 = [];
    df.ExtraVar1 = [];
    
    toDelete = char(df.GPSDateTime(:)) == '00000000-000000';
    toDelete = all(toDelete,2);
    df(toDelete,:) = [];

    strtime = char(df.GPSDateTime(1))
    
    year    = str2double(strtime(1:4));
    month   = str2double(strtime(5:6));
    day     = str2double(strtime(7:8));
    hour    = str2double(strtime(10:11));
    minute  = str2double(strtime(12:13));
    second  = str2double(strtime(14:15));

    newtitle = strcat(num2str(year,'%04.f'), num2str(month,'%02.f'), num2str(day,'%02.f'), '_', num2str(hour,'%02.f'), num2str(minute,'%02.f'), '_', 'wamorewindpack', '.mat')

    plot(df.GPSAltitude_mAboveMSL_);
    title('GPS Altitude')
    ylabel('ft')
    [x, ~] = ginput;
    close
    
    for j = 1:1:length(x)
        
        nfirst = floor(x(j)-100)
        nlast  = ceil(x(j)+250)
        
        [maxalt idx_maxalt] = max(df.GPSAltitude_mAboveMSL_(nfirst:nlast));

        idx_maxalt = idx_maxalt + nfirst;

        plot(df.GPSAltitude_mAboveMSL_(nfirst:nlast))
        
        for j = idx_maxalt:1:nlast
            if(df.GPSAltitude_mAboveMSL_(j) > maxalt*.995)
                idx_maxalt = j;
            end
        end

        idx_maxalt

        endidx = length(df.GPSAltitude_mAboveMSL_)

        plot(df.GPSAltitude_mAboveMSL_(idx_maxalt:nlast))

        gl = mode(df.GPSAltitude_mAboveMSL_(idx_maxalt:endidx))
        for j = endidx:-1:idx_maxalt
            if(df.GPSAltitude_mAboveMSL_(j) < gl*1.005)
                idx_minalt = j;
            end
        end

        ds{1,i} = df(idx_maxalt:idx_minalt,:);
%        ds{2,i} = df{idx_maxalt,4}; % date YYMMDD
%        ds{3,i} = df{idx_maxalt,5}; % time HHMMSS
        ds{2,i} = strcat(num2str(year,'%04.f'), num2str(month,'%02.f'), num2str(day,'%02.f'));
        ds{3,i} = strcat(num2str(hour,'%02.f'), num2str(minute,'%02.f'), num2str(second,'%02.f'));
        
        fname = dirData(i).name;
        fname = fname(1:(end-4));
        fname = strcat(fname,'.mat');
        
        save(newtitle, 'ds');

    end
end


