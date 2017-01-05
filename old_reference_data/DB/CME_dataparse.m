%% Cron runs script 01:11 CEST or 00:11 CET on local machine.

%tic
%% Logging setup
fid_log = fopen('/Users/jvr23/Documents/MATLAB/DB/CME_dataparse.log', 'a');
fid_report_date = fopen('/Users/jvr23/Documents/MATLAB/DB/CME_report_date.log', 'r');

%% Get the ticker tables
CBOTtickers =...
    readtable('/Users/jvr23/Documents/Trading/Exchange_list/CBOT/CBOT_contract_months_calendar.csv');
CMEtickers =...
    readtable('/Users/jvr23/Documents/Trading/Exchange_list/CME/CME_contract_months_calendar.csv');
NYMEXtickers = ...
    readtable('/Users/jvr23/Documents/Trading/Exchange_list/NYMEX/NYMEX_contract_months_calendar.csv');
COMEXtickers = ...
    readtable('/Users/jvr23/Documents/Trading/Exchange_list/COMEX/COMEX_contract_months_calendar.csv');

%% Convert CME report into arrays
%tic
fid_stlags = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stlags.txt');
fid_stlcur = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stlcur.txt');
fid_stleqt = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stleqt.txt');
fid_stlint = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stlint.txt');
fid_stlnymex = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stlnymex.txt');
fid_stlcomex = fopen('/Users/jvr23/Documents/Trading/Exchange_list/stlcomex.txt');

% [~, stlags_lines_count] = unix('wc -l /Users/admin/Documents/Trading/Exchange_list/stlags.txt');
[~, stlcur_lines_count] = unix('wc -l /Users/jvr23/Documents/Trading/Exchange_list/stlcur.txt');
% [~, stleqt_lines_count] = unix('wc -l /Users/admin/Documents/Trading/Exchange_list/stleqt.txt');
% [~, stlint_lines_count] = unix('wc -l /Users/admin/Documents/Trading/Exchange_list/stlint.txt');
% [~, stlnymex_lines_count] = unix('wc -l /Users/admin/Documents/Trading/Exchange_list/stlnymex.txt');
% [~, stlcomex_lines_count] = unix('wc -l /Users/admin/Documents/Trading/Exchange_list/stlcomex.txt');

stlags_lines_count=1230; % cell2mat(textscan(stlags_lines_count,'%u %*s'));
stlcur_lines_count=cell2mat(textscan(stlcur_lines_count,'%u %*s'));
stleqt_lines_count=300; % cell2mat(textscan(stleqt_lines_count,'%u %*s'));
stlint_lines_count=300; % cell2mat(textscan(stlint_lines_count,'%u %*s'));
stlnymex_lines_count=2500; % cell2mat(textscan(stlnymex_lines_count,'%u %*s'));
stlcomex_lines_count=400; % cell2mat(textscan(stlcomex_lines_count,'%u %*s'));

% Read settle files line-by-line and save it into cell array
stlags_array=cell(stlags_lines_count,1);
stlcur_array=cell(stlcur_lines_count,1);
stleqt_array=cell(stleqt_lines_count,1);
stlint_array=cell(stlint_lines_count,1);
stlnymex_array=cell(stlnymex_lines_count,1);
stlcomex_array=cell(stlcomex_lines_count,1);

tline = fgetl(fid_stlags);
for line=1:stlags_lines_count
    stlags_array{line}=tline;
    tline = fgetl(fid_stlags);
end
tline = fgetl(fid_stlcur);
for line=1:stlcur_lines_count
    stlcur_array{line}=tline;
    tline = fgetl(fid_stlcur);
end
tline = fgetl(fid_stleqt);
for line=1:stleqt_lines_count
    stleqt_array{line}=tline;
    tline = fgetl(fid_stleqt);
end
tline = fgetl(fid_stlint);
for line=1:stlint_lines_count
    stlint_array{line}=tline;
    tline = fgetl(fid_stlint);
end
tline = fgetl(fid_stlnymex);
for line=1:stlnymex_lines_count
    stlnymex_array{line}=tline;
    tline = fgetl(fid_stlnymex);
end
tline = fgetl(fid_stlcomex);
for line=1:stlcomex_lines_count
    stlcomex_array{line}=tline;
    tline = fgetl(fid_stlcomex);
end
fclose(fid_stlags);
fclose(fid_stlcur);
fclose(fid_stleqt);
fclose(fid_stlint);
fclose(fid_stlnymex);
fclose(fid_stlcomex);
%toc

%% Check/parse/export report date
last_report_date=fscanf(fid_report_date,'%s');
current_report_date=regexp(stlags_array{1},'\d+/\d+/\d+','match');
trade_date=datevec(current_report_date,'mm/dd/yy'); % month,day,year
trade_year=mod(trade_date(1),100);
trade_date=trade_date(2:3); % month,day
fprintf(fid_log,'---------------------------------------------------------\n');
fprintf(fid_log,...
    'Datetime:%s,Tradedate:%s\n',...
    datestr(now,'yyyy-mm-dd,HH:MM'),...
    datestr(current_report_date,'yyyy-mm-dd'));
if strcmp(current_report_date,last_report_date)
    fprintf(fid_log,...
        'Current report date equals to last report date.Terminating the script.\n');
    fclose(fid_log);
    fclose(fid_report_date);
    exit;
end
fid_report_date=fopen('/Users/admin/Documents/MATLAB/DB/CME_report_date.log','w');
fprintf(fid_report_date,char(current_report_date));

%% Get cell array with matrices with enumerated days and months for each ticker
% Table decomposition
%tic
ticker_array_CBOT=table2array(CBOTtickers(:,1)); % CBOT tickers
ticker_array_CME=table2array(CMEtickers(:,1)); % CME tickers
ticker_array_NYMEX=table2array(NYMEXtickers(:,1)); % NYMEX tickers
ticker_array_COMEX=table2array(COMEXtickers(:,1)); % COMEX tickers
date_matrix_CBOT=table2array(CBOTtickers(:,2:end)); % Start_month,Start_day,End_month,End_day
date_matrix_CME=table2array(CMEtickers(:,2:end)); % Start_month,Start_day,End_month,End_day
date_matrix_NYMEX=table2array(NYMEXtickers(:,2:end)); % Start_month,Start_day,End_month,End_day
date_matrix_COMEX=table2array(COMEXtickers(:,2:end)); % Start_month,Start_day,End_month,End_day
isSMgreaterthanEM_CBOT=date_matrix_CBOT(:,1)>date_matrix_CBOT(:,3);
isSMgreaterthanEM_CME=date_matrix_CME(:,1)>date_matrix_CME(:,3);
isSMgreaterthanEM_NYMEX=date_matrix_NYMEX(:,1)>date_matrix_NYMEX(:,3);
isSMgreaterthanEM_COMEX=date_matrix_COMEX(:,1)>date_matrix_COMEX(:,3);
enum_months_days_CBOT=cell(length(isSMgreaterthanEM_CBOT),2);
enum_months_days_CME=cell(length(isSMgreaterthanEM_CME),2);
enum_months_days_NYMEX=cell(length(isSMgreaterthanEM_NYMEX),2);
enum_months_days_COMEX=cell(length(isSMgreaterthanEM_COMEX),2);

for row=1:length(enum_months_days_CBOT)
    if isSMgreaterthanEM_CBOT(row)
        enum_months_days_CBOT(row,1)={[date_matrix_CBOT(row,1):12,1:date_matrix_CBOT(row,3)]};
    else
        enum_months_days_CBOT(row,1)={date_matrix_CBOT(row,1):date_matrix_CBOT(row,3)};
    end
    % Days on which we want to retrieve data in last month
    % Explanation: Every day in the first month for particular ticker will
    % be downloaded. On the other hand we want to finish downloading the
    % particular ticker ie. on 10th day on last trading month.
    enum_months_days_CBOT(row,2)={1:date_matrix_CBOT(row,4)};
end

for row=1:length(enum_months_days_CME)
    if isSMgreaterthanEM_CME(row)
        enum_months_days_CME(row,1)={[date_matrix_CME(row,1):12,1:date_matrix_CME(row,3)]};
    else
        enum_months_days_CME(row,1)={date_matrix_CME(row,1):date_matrix_CME(row,3)};
    end
    enum_months_days_CME(row,2)={1:date_matrix_CME(row,4)};
end

for row=1:length(enum_months_days_NYMEX)
    if isSMgreaterthanEM_NYMEX(row)
        enum_months_days_NYMEX(row,1)={[date_matrix_NYMEX(row,1):12,1:date_matrix_NYMEX(row,3)]};
    else
        enum_months_days_NYMEX(row,1)={date_matrix_NYMEX(row,1):date_matrix_NYMEX(row,3)};
    end
    enum_months_days_NYMEX(row,2)={1:date_matrix_NYMEX(row,4)};
end

for row=1:length(enum_months_days_COMEX)
    if isSMgreaterthanEM_COMEX(row)
        enum_months_days_COMEX(row,1)={[date_matrix_COMEX(row,1):12,1:date_matrix_COMEX(row,3)]};
    else
        enum_months_days_COMEX(row,1)={date_matrix_COMEX(row,1):date_matrix_COMEX(row,3)};
    end
    enum_months_days_COMEX(row,2)={1:date_matrix_COMEX(row,4)};
end
%toc
%% Get indexes of tickers to download according to trade_date
%tic
indexes_CBOT=[];
for row=1:length(enum_months_days_CBOT)
    % Test if month today is download month but not last download month.
    % If so >>> we want add this index to our ticker download list
    if find(trade_date(1,1)==enum_months_days_CBOT{row,1}(1:end-1),1,'first')
        indexes_CBOT(end+1,1)=row; %#ok<SAGROW>
        % Test if month today is last download month. If so we need to test
        % if our particular download day is in last month download day list
    elseif find(trade_date(1,1)==enum_months_days_CBOT{row,1}(end),1,'first')
        if find(trade_date(1,2)==enum_months_days_CBOT{row,2},1,'first');
            indexes_CBOT(end+1,1)=row; %#ok<SAGROW>
        end
    end
end

indexes_CME=[];
for row=1:length(enum_months_days_CME)
    % Test if month today is download month but not last download month.
    % If so >>> we want add this index to our ticker download list
    if find(trade_date(1,1)==enum_months_days_CME{row,1}(1:end-1),1,'first')
        indexes_CME(end+1,1)=row; %#ok<SAGROW>
        % Test if month today is last download month. If so we need to test
        % if our particular download day is in last month download day list
    elseif find(trade_date(1,1)==enum_months_days_CME{row,1}(end),1,'first')
        if find(trade_date(1,2)==enum_months_days_CME{row,2},1,'first');
            indexes_CME(end+1,1)=row; %#ok<SAGROW>
        end
    end
end

indexes_NYMEX=[];
for row=1:length(enum_months_days_NYMEX)
    % Test if month today is download month but not last download month.
    % If so >>> we want add this index to our ticker download list
    if find(trade_date(1,1)==enum_months_days_NYMEX{row,1}(1:end-1),1,'first')
        indexes_NYMEX(end+1,1)=row; %#ok<SAGROW>
        % Test if month today is last download month. If so we need to test
        % if our particular download day is in last month download day list
    elseif find(trade_date(1,1)==enum_months_days_NYMEX{row,1}(end),1,'first')
        if find(trade_date(1,2)==enum_months_days_NYMEX{row,2},1,'first');
            indexes_NYMEX(end+1,1)=row; %#ok<SAGROW>
        end
    end
end

indexes_COMEX=[];
for row=1:length(enum_months_days_COMEX)
    % Test if month today is download month but not last download month.
    % If so >>> we want add this index to our ticker download list
    if find(trade_date(1,1)==enum_months_days_COMEX{row,1}(1:end-1),1,'first')
        indexes_COMEX(end+1,1)=row; %#ok<SAGROW>
        % Test if month today is last download month. If so we need to test
        % if our particular download day is in last month download day list
    elseif find(trade_date(1,1)==enum_months_days_COMEX{row,1}(end),1,'first')
        if find(trade_date(1,2)==enum_months_days_COMEX{row,2},1,'first');
            indexes_COMEX(end+1,1)=row; %#ok<SAGROW>
        end
    end
end
%toc
%% Append proper year to download symbols
% If current month is in 8:12 then we append next year to all leap
% download symbols.
% If current month is in 1:5 then we append this year to all leap download
% symbols.
%tic

% CBOT
next_year=8:12;
current_year=1:5;
dl_symbol=ticker_array_CBOT(indexes_CBOT);
leap_dl_symbol=intersect(dl_symbol,ticker_array_CBOT(isSMgreaterthanEM_CBOT));
common_dl_symbol=setdiff(dl_symbol,ticker_array_CBOT(isSMgreaterthanEM_CBOT));
complete_symbol_CBOT={};
if find(trade_date(1)==next_year,1,'first')
    complete_symbol_CBOT=strcat(leap_dl_symbol,num2str(trade_year+1));
elseif find(trade_date(1)==current_year,1,'first')
    complete_symbol_CBOT=strcat(leap_dl_symbol,num2str(trade_year));
end
complete_symbol_CBOT=[complete_symbol_CBOT;strcat(common_dl_symbol,num2str(trade_year))];
complete_symbol_CBOT=sort(complete_symbol_CBOT);

% CME
next_year=8:12;
current_year=1:5;
dl_symbol=ticker_array_CME(indexes_CME);
leap_dl_symbol=intersect(dl_symbol,ticker_array_CME(isSMgreaterthanEM_CME));
common_dl_symbol=setdiff(dl_symbol,ticker_array_CME(isSMgreaterthanEM_CME));
complete_symbol_CME={};
if find(trade_date(1)==next_year,1,'first')
    complete_symbol_CME=strcat(leap_dl_symbol,num2str(trade_year+1));
elseif find(trade_date(1)==current_year,1,'first')
    complete_symbol_CME=strcat(leap_dl_symbol,num2str(trade_year));
end
complete_symbol_CME=[complete_symbol_CME;strcat(common_dl_symbol,num2str(trade_year))];
complete_symbol_CME=sort(complete_symbol_CME);

% NYMEX
next_year=8:12;
current_year=1:5;
dl_symbol=ticker_array_NYMEX(indexes_NYMEX);
% Some of NYMEX symbols data ends in month which is not their contract
% month. For example CLF(January contract ends in December). So we need to
% enumerate manually which of these symbols are "leap_dl_symbols". Our isSMgreaterthanEM_NYMEX
% algorhytm will not work here because StartMonth is lesser than EndMonth
% even we have leap_dl_symbol.
%leap_dl_symbol=intersect(dl_symbol,ticker_array_NYMEX(isSMgreaterthanEM_NYMEX));
%common_dl_symbol=setdiff(dl_symbol,ticker_array_NYMEX(isSMgreaterthanEM_NYMEX));
leap_symbol={...
    'HOF';'HOG';'HOH';...
    'NGF';'NGG';'NGH';...
    'CLF';'CLG';'CLH';...
    'QMF';'QMG';'QMH';...
    'QGF';'QGG';'QGH';...
    'QGF';'QGG';'QGH';...
    'RBF';'RBG';'RBH';...
    'PAH';...
    'PLF';'PLJ';...
    };
leap_dl_symbol=intersect(dl_symbol,leap_symbol);
common_dl_symbol=setdiff(dl_symbol,leap_symbol);
complete_symbol_NYMEX={};
if find(trade_date(1)==next_year,1,'first')
    complete_symbol_NYMEX=strcat(leap_dl_symbol,num2str(trade_year+1));
elseif find(trade_date(1)==current_year,1,'first')
    complete_symbol_NYMEX=strcat(leap_dl_symbol,num2str(trade_year));
end
complete_symbol_NYMEX=[complete_symbol_NYMEX;strcat(common_dl_symbol,num2str(trade_year))];
complete_symbol_NYMEX=sort(complete_symbol_NYMEX);

% COMEX
next_year=8:12;
current_year=1:5;
dl_symbol=ticker_array_COMEX(indexes_COMEX);
leap_dl_symbol=intersect(dl_symbol,ticker_array_COMEX(isSMgreaterthanEM_COMEX));
common_dl_symbol=setdiff(dl_symbol,ticker_array_COMEX(isSMgreaterthanEM_COMEX));
complete_symbol_COMEX={};
if find(trade_date(1)==next_year,1,'first')
    complete_symbol_COMEX=strcat(leap_dl_symbol,num2str(trade_year+1));
elseif find(trade_date(1)==current_year,1,'first')
    complete_symbol_COMEX=strcat(leap_dl_symbol,num2str(trade_year));
end
complete_symbol_COMEX=[complete_symbol_COMEX;strcat(common_dl_symbol,num2str(trade_year))];
complete_symbol_COMEX=sort(complete_symbol_COMEX);
%toc
%% Postgres query build
% Table columns:
% data_vendor_name,exchange_symbol,vendor_symbol,complete_symbol,contract_month,
% price_date,O,H,L,Last,Settle,Volume,OI,created,modified
% For this case exchange_symbol==vendor_symbol
%tic
data_vendor_name={'CME'};

% exchange_symbol column build
complete_symbol=[...
    complete_symbol_CBOT;...
    complete_symbol_CME;...
    complete_symbol_NYMEX;...
    complete_symbol_COMEX
    ];
fprintf(fid_log,'Downloaded symbols:%u\n',length(complete_symbol));

exchange_symbol=...
    cellstr(cellfun(@(x) x(1,1:length(x)-3),...
    complete_symbol,'UniformOutput',false));

% contract_month column build
CMmap=readtable('/Users/jvr23/Documents/Trading/Exchange_list/Contract_months_map.csv');
CMmap=table2cell(CMmap(:,[1,3]));

contract_month_CBOT=cellstr(cellfun(@(x) x(1,end-2), complete_symbol_CBOT));
[~,id]=ismember(contract_month_CBOT,CMmap(:,2));
contract_month_CBOT=CMmap(id);
contract_month_CBOT=...
    strcat(contract_month_CBOT,...
    cellfun(@(x) x(:,end-1:end), complete_symbol_CBOT,'UniformOutput',false));

contract_month_CME=cellstr(cellfun(@(x) x(1,end-2), complete_symbol_CME));
[~,id]=ismember(contract_month_CME,CMmap(:,2));
contract_month_CME=CMmap(id);
contract_month_CME=...
    strcat(contract_month_CME,...
    cellfun(@(x) x(:,end-1:end), complete_symbol_CME,'UniformOutput',false));

contract_month_NYMEX=cellstr(cellfun(@(x) x(1,end-2), complete_symbol_NYMEX));
[~,id]=ismember(contract_month_NYMEX,CMmap(:,2));
contract_month_NYMEX=CMmap(id);
contract_month_NYMEX=...
    strcat(contract_month_NYMEX,...
    cellfun(@(x) x(:,end-1:end), complete_symbol_NYMEX,'UniformOutput',false));

contract_month_COMEX=cellstr(cellfun(@(x) x(1,end-2), complete_symbol_COMEX));
[~,id]=ismember(contract_month_COMEX,CMmap(:,2));
contract_month_COMEX=CMmap(id);
contract_month_COMEX=...
    strcat(contract_month_COMEX,...
    cellfun(@(x) x(:,end-1:end), complete_symbol_COMEX,'UniformOutput',false));

contract_month=[...
    contract_month_CBOT;...
    contract_month_CME;...
    contract_month_NYMEX;
    contract_month_COMEX];
%toc
% price_date column build
price_date=repmat(datestr(current_report_date,'yyyy-mm-dd'),length(complete_symbol),1);
price_date=cellstr(price_date);
%% Load {CBOT,CME,NYMEX,COMEX}_products.csv
% (exchange_sybol-settle_file_symbol_description-settle_file)
% We will look for appropriate symbols in CME settlements reports.
CBOTproductsmap=readtable('/Users/jvr23/Documents/Trading/Exchange_list/CBOT/CBOT_products.csv');
CMEproductsmap=readtable('/Users/jvr23/Documents/Trading/Exchange_list/CME/CME_products.csv');
NYMEXproductsmap=readtable('/Users/jvr23/Documents/Trading/Exchange_list/NYMEX/NYMEX_products.csv');
COMEXproductsmap=readtable('/Users/jvr23/Documents/Trading/Exchange_list/COMEX/COMEX_products.csv');
CBOTproductsmap=table2array(CBOTproductsmap(:,[2,4,5]));
CMEproductsmap=table2array(CMEproductsmap(:,[2,4,5]));
NYMEXproductsmap=table2array(NYMEXproductsmap(:,[2,4,5]));
COMEXproductsmap=table2array(COMEXproductsmap(:,[2,4,5]));

productsmap=[...
    CBOTproductsmap;...
    CMEproductsmap;...
    NYMEXproductsmap;...
    COMEXproductsmap];
[~,id]=ismember(exchange_symbol,productsmap(:,1));
% settle_file_id = globex_symbol,CME_Settlement_file_description,Settle_file
products_info=[productsmap(id,1),productsmap(id,2),productsmap(id,3),contract_month];
data_result=cell(length(products_info),7);
for row=1:length(products_info)
    switch products_info{row,3}
        case 'stlags.txt'
            desc_index=find(strcmp(stlags_array,products_info{row,2}));
            if length(desc_index)~=1
                fprintf(fid_log,...
                    'More occurences of %s in %s\n',...
                    products_info{row,2},...
                    products_info{row,3});
            end
            month_index=...
                find(~cellfun(@isempty,cellfun(@(line) strfind(line,products_info{row,4}),...
                stlags_array,'UniformOutput' , false)));
            data=find(month_index>desc_index(1),1,'first');
            data=stlags_array(month_index(data));
            % Month,Open,High,Low,Last,Settle,PCTchange,est.volume,...prior
            % day info
            data=textscan(data{1},'%*s %s %s %s %s %s %*s %s %*s %*s %s');
            data_result(row,:)=data;
        
        case 'stlcur.txt'
            
        case 'stleqt.txt'
            desc_index=find(strcmp(stleqt_array,products_info{row,2}));
            if length(desc_index)~=1
                fprintf(fid_log,...
                    'More occurences of %s in %s\n',...
                    products_info{row,2},...
                    products_info{row,3});
            end
            month_index=...
                find(~cellfun(@isempty,cellfun(@(line) strfind(line,products_info{row,4}),...
                stleqt_array,'UniformOutput' , false)));
            data=find(month_index>desc_index(1),1,'first');
            data=stleqt_array(month_index(data));
            % Month,Open,High,Low,Last,Settle,PCTchange,est.volume,...prior
            % day info
            data=textscan(data{1},'%*s %s %s %s %s %s %*s %s %*s %*s %s');
            data_result(row,:)=data;
        
        case 'stlint.txt'
            desc_index=find(strcmp(stlint_array,products_info{row,2}));
            if length(desc_index)~=1
                fprintf(fid_log,...
                    'More occurences of %s in %s\n',...
                    products_info{row,2},...
                    products_info{row,3});
            end
            month_index=...
                find(~cellfun(@isempty,cellfun(@(line) strfind(line,products_info{row,4}),...
                stlint_array,'UniformOutput' , false)));
            data=find(month_index>desc_index(1),1,'first');
            data=stlint_array(month_index(data));
            % Month,Open,High,Low,Last,Settle,PCTchange,est.volume,...prior
            % day info
            data=textscan(data{1},'%*s %s %s %s %s %s %*s %s %*s %*s %s');
            data_result(row,:)=data;
        
        case 'stlnymex.txt'
            desc_index=find(strcmp(stlnymex_array,products_info{row,2}));
            if length(desc_index)~=1
                fprintf(fid_log,...
                    'More occurences of %s in %s\n',...
                    products_info{row,2},...
                    products_info{row,3});
            end
            month_index=...
                find(~cellfun(@isempty,cellfun(@(line) strfind(line,products_info{row,4}),...
                stlnymex_array,'UniformOutput' , false)));
            data=find(month_index>desc_index(1),1,'first');
            data=stlnymex_array(month_index(data));
            % Month,Open,High,Low,Last,Settle,PCTchange,est.volume,...prior
            % day info
            data=textscan(data{1},'%*s %s %s %s %s %s %*s %s %*s %*s %s');
            data_result(row,:)=data;
            
        case 'stlcomex.txt'
            desc_index=find(strcmp(stlcomex_array,products_info{row,2}));
            if length(desc_index)~=1
                fprintf(fid_log,...
                    'More occurences of %s in %s\n',...
                    products_info{row,2},...
                    products_info{row,3});
            end
            month_index=...
                find(~cellfun(@isempty,cellfun(@(line) strfind(line,products_info{row,4}),...
                stlcomex_array,'UniformOutput' , false)));
            data=find(month_index>desc_index(1),1,'first');
            data=stlcomex_array(month_index(data));
            % Month,Open,High,Low,Last,Settle,PCTchange,est.volume,...prior
            % day info
            data=textscan(data{1},'%*s %s %s %s %s %s %*s %s %*s %*s %s');
            data_result(row,:)=data;
    end
end

%% Parse data_result into numeric(19,4) format.
% We have 4 types of conversion
data_result=cellfun(@(cell) cellstr(cell),data_result);
data_result=cellfun(@(cell) strrep(cell,'A',''),data_result,'UniformOutput',false);
data_result=cellfun(@(cell) strrep(cell,'B',''),data_result,'UniformOutput',false);

% test for empty cells
test_matrix=cellfun(@isempty,data_result);
if any(test_matrix(:))
    fprintf(fid_log,'Empty value [] in dataresult.\n');
    data_result(test_matrix)={'0'};
end
% test for '----' cells directly from exchange
test_matrix=cellfun(@(x) strcmp('----',x),data_result);
if any(test_matrix(:))
    fprintf(fid_log,'Empty value ---- in dataresult.\n');
    data_result(test_matrix)={'0'};
end

% Conversion to floats
for row=1:length(exchange_symbol)
    switch exchange_symbol{row}
        case {'KE','ZC','ZO','ZS','ZW'}
            for column=1:size(data_result,2)-2
                number=str2double(strsplit(data_result{row,column},''''));
                number(2)=number(2)/8;
                data_result{row,column}=num2str(number(1)+number(2));
            end
        case {'UB','ZB'}
            for column=1:size(data_result,2)-2
                number=str2double(strsplit(data_result{row,column},''''));
                number(2)=number(2)/32;
                data_result{row,column}=num2str(number(1)+number(2));
            end
        case {'ZF','ZN','ZT'}
            for column=1:size(data_result,2)-2
                number=str2double(strsplit(data_result{row,column},''''));
                number(2)=number(2)/32;
                data_result{row,column}=num2str(number(1)+number(2));
            end
    end
    
end

% SQL query rows
query_rows=...
    [...
    repmat(data_vendor_name,length(complete_symbol),1),...
    exchange_symbol,...
    exchange_symbol,...
    complete_symbol,...
    contract_month,...
    price_date,...
    data_result...
    ];

fprintf(fid_log,'Data parsed succesfully.\n');
fclose(fid_log);
fclose(fid_report_date);
save('/Users/admin/Documents/MATLAB/DB/last_query.mat','query_rows');
%toc
% exit