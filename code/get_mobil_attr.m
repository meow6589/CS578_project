% get attributes from phone logs
% # of voice calls
% night-call ratio
% call duration: total duration

load('../Data/dataset_85.mat','dataset');
load('../Data/friend_ground_truth_85.mat','friend_ground_truth');

% get hashed number mapping with person id
% iterate through every subject data
hashId_map = zeros(1,numel(dataset));
for i = 1:numel(dataset)
    subject = dataset(i);
    % get hashed number
    if isempty(subject.my_hashedNumber)
        hashId_map(i)=-1;
    else
        hashId_map(i) = subject.my_hashedNumber;
    end
end

attr = [];

% iterate through every subject data
for i = 1:numel(dataset)
    subject = dataset(i);
    logs = subject.comm;
    numOfCalls = containers.Map;
    durOfCalls = containers.Map;
    nightCalls = containers.Map;
    % iterate through every phone log
    for j = 1:numel(logs)
        contact = logs(j).contact;
        if contact ~= -1
            if ~isempty(find(hashId_map==contact))
                contact = find(hashId_map==contact);
                formatOut = 'HH';
                hr_str = datestr(logs(j).date,formatOut,'local');
                if strcmp(logs(j).direction,'Missed')||isempty(logs(j).duration)
                    duration = 0;
                else
                    duration = logs(j).duration;
                end
                
                if isKey(numOfCalls,num2str(contact))
                    numOfCalls(num2str(contact)) = numOfCalls(num2str(contact))+1;
                    durOfCalls(num2str(contact)) = durOfCalls(num2str(contact))+duration;
                    if (str2double(hr_str) > 19) || (str2double(hr_str) < 5)
                        nightCalls(num2str(contact)) = nightCalls(num2str(contact))+duration;
                    end
                else
                    numOfCalls(num2str(contact)) = 1;
                    durOfCalls(num2str(contact)) = duration;
                    if (str2double(hr_str) > 19) || (str2double(hr_str) < 5)
                        nightCalls(num2str(contact)) = duration;
                    else
                        nightCalls(num2str(contact)) = 0.0;
                    end
                end
                
                %if contact==252 && i==15
                %durOfCalls(num2str(contact))
                %end
            end
        end
    end
    
    % store as one attribute
    allKeys = keys(numOfCalls);
    for j = 1:numel(allKeys)
        oneKey = allKeys(j);
        label = friend_ground_truth(i,str2double(oneKey));
        if isnan(label)
            label = friend_ground_truth(str2double(oneKey),i);
        end
        if isnan(label)
            label = 0;
        end
        if durOfCalls(char(oneKey))==0
            oneEntry = [i,str2double(oneKey),numOfCalls(char(oneKey)),durOfCalls(char(oneKey)),0,label];
        else
            oneEntry = [i,str2double(oneKey),numOfCalls(char(oneKey)),durOfCalls(char(oneKey)),1.0*nightCalls(char(oneKey))/durOfCalls(char(oneKey)),label];
        end
        
        %oneEntry
        attr = [attr;oneEntry];
    end
end

csvwrite('../Data/feature_85.csv', attr);
