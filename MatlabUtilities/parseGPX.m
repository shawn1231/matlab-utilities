function dat = parseGPX(filename,convert_to_ft,write_csv)
%   PARSEGPX converts GPS data stored in a GPX file to a CSV formatted
%   file, note this function has been prepared specifically for the BadElf
%   GPS Pro +
%
%   dat = parseGPX(filename,convert_to_ft,write_csv)
%
%   INPUTS:
%   filename is the name of the file to be read (should end in .gpx)
%   convert_to_ft is a flag which indicates whether the altitude data
%   should be converted from m to ft
%   write_csv is a flag which indicates whether the output table should be
%   automatically written to a csv file with the same name as the original
%   file (but a .csv extension)
%   OUTPUTS:
%   dat is the data table output

%--------------------------------------------------------------------------
% Created by:       Shawn Herrington
% Date created:     04/11/2019
% Purpose:          To convert BadElf GPS Pro + GPX files into csv
% Notes:            to convert GPX from other devices will require
%                   modifications to how the data fields are split up
%--------------------------------------------------------------------------

    if nargin < 3
        write_csv = 0; % default to no csv output
        if nargin < 2
            convert_to_ft = 0; % default to no unit conversion
        end
    end

    % use parseXML function (found online) to convert xml document to
    % matlab struct
    mlstruct = parseXML(filename);

    % lat and lng labels stored here
    number_of_name_fields = length(mlstruct.Children(6).Children(4).Children(2).Attributes);

    for i = 1:1:number_of_name_fields
        colname(1,i) = {mlstruct.Children(6).Children(4).Children(2).Attributes(i).Name};
    end

    % other standard fields are stored here (ele,time,hdop), we are not
    % going to use time as it is given to us
    number_of_other_fields = length(mlstruct.Children(6).Children(4).Children(2).Children)-1;

    % start where we left off, don't overwrite other labels
    colname_start = length(colname);

    for i = 1:1:number_of_other_fields
        colname(1,colname_start + i) = {mlstruct.Children(6).Children(4).Children(2).Children(i).Name};
    end

    % extended fields (unique to BadElf) are stored here
    % (speed,baro,baroPress)
    number_of_extension_fields = length(mlstruct.Children(6).Children(4).Children(2).Children(4).Children);

    % start where we left off, don't overwrite other labels
    colname_start = length(colname);

    for i = 1:1:number_of_extension_fields
        colname(1,colname_start + i) = {mlstruct.Children(6).Children(4).Children(2).Children(4).Children(i).Name};
    end

    % this is the number of rows of data, subtract one off the end to make
    % it an even number
    number_of_track_pts = max(size(mlstruct.Children(6).Children(4).Children))-1;
    % number of rows of data is actually 2x the number of unique data
    % points, we are going to create an iterator here which skips empty
    % rows, the first row is always empty and we have already remove the
    % last row (also empty)
    for i = 2:2:number_of_track_pts

        % lat,lng here
        for j = 1:1:number_of_name_fields
            coldata(i,j) = str2num(mlstruct.Children(6).Children(4).Children(i).Attributes(j).Value);
        end

        coldata_start = 2;

        % ele,time,hdop here
        for j = 1:1:number_of_other_fields
            if j ~= 2
                coldata(i,coldata_start + j) = str2num(mlstruct.Children(6).Children(4).Children(i).Children(j).Children.Data);
            else
            % we are keeping time separately since the rest of the array is
            % numeric
                time(i,1) = string(mlstruct.Children(6).Children(4).Children(i).Children(j).Children(1).Data);
            end
        end

        coldata_start = 5;

        % extended fields here
        for j = 1:1:number_of_extension_fields
            coldata(i,coldata_start + j) = str2num(mlstruct.Children(6).Children(4).Children(i).Children(4).Children(j).Children.Data);
        end
    end

    % clean up the bar variable names from the extension fields
    for i = 1:1:length(colname)
        colname{i}(colname{i} == ':') = '_';
    end

    % remove every other row since there are two rows in the xml for each track point
    coldata(1:2:number_of_track_pts,:) = [];
    time(1:2:number_of_track_pts,:) = [];
    % remove the empty column where time should be
    coldata(:,4) = [];

    % convert gps time string to something a little more intelligent
    for i = 1:1:length(time)
        [year(i,1),month(i,1),day(i,1),hour(i,1),minute(i,1),second(i,1),zone(i,1)] = convert_gps_time(time(i));
    end

    dat = table(coldata(:,1),coldata(:,2),coldata(:,3),coldata(:,4),coldata(:,5),coldata(:,6),coldata(:,7),year,month,day,hour,minute,second,zone);
    dat.Properties.VariableNames = {colname{1:3},colname{5:8},'year','month','day','hour','minute','second','zone'};

    if convert_to_ft
        factor = unitsratio('ft','m'); % get unit ratio
        % convert both elevation vars
        dat.ele = factor.*dat.ele;
        dat.badelf_baroEle = factor.*dat.badelf_baroEle;
    end

    if write_csv
        % do some processing to get a new filename with the correct
        % extension
        mod_filename = filename;
        mod_filename(end-2:end) = 'csv';
        % write the table to csv using the built-in MATLAB function
        writetable(dat,mod_filename);
    end

end

