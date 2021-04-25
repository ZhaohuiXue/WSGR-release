close all
clear all
clc

%% real data set
load Indian_pines_corrected;
img = indian_pines_corrected;
clear indian_pines_corrected;

sz = size(img);
img_src = double(img);
clear img;

img_src = reshape(img_src,sz(1)*sz(2),sz(3));
Ydata_all_DR_org = mapminmax(img_src');
clear img_src

Ydata_all_DR_org = Ydata_all_DR_org';
%% ground truth image
load Indian_pines_gt;
img_gt = reshape(indian_pines_gt,sz(1)*sz(2),1);
trainall = [find(img_gt~=0) img_gt(find(img_gt~=0))];
trainall = trainall';
clear indian_pines_gt;
clear img_gt;

%% parameters
MMiter  = [1:10];  % number of Mont Carlo (MC) runs
per_class_all = [50];%for dictionary
no_classes = 16;

show_CMap = 'yes'; % yes | no
mu = 4;        % MLL soomthness parameter

lambda_all = 0.001;%[1e-10 1e-8 1e-6 1e-4 1e-2 1];
gamma_all  = 1;%[1e-2 1e-1 1 1e1 1e2 1e3];

%% Generate neighborhood
classifier_type_all=cellstr(strvcat('SGR'));
neighorhood_method_all = cellstr(strvcat('fix-weighted'));%noneighbor (SGR) | fix | fix-weighted (WSGR)
for i_neighborhood=1:length(neighorhood_method_all)
    neighorhood_method=char(neighorhood_method_all(i_neighborhood));
    
    if strcmp(neighorhood_method,'noneighbor')
        patchSize_all = [0];
    else
        patchSize_all = [9];
    end
    
    for i_patchSize = 1:length(patchSize_all)
        patchSize = patchSize_all(i_patchSize);
        if strcmp(neighorhood_method,'fix')
            %% fixed window
            Ydata_all_DR = reshape(Ydata_all_DR_org,sz(1),sz(2),sz(3));
            padcam = padarray(Ydata_all_DR,[patchSize patchSize],'symmetric','both');
            [m,n] = size(padcam);
            ImagePatches = zeros(sz(3),sz(1)*sz(2));
            
            count = 1;
            for j = patchSize+1:sz(2)+patchSize
                for i = patchSize+1:sz(1)+patchSize
                    temp = padcam(i-(patchSize-1)/2:i+(patchSize-1)/2, j-(patchSize-1)/2:j+(patchSize-1)/2,:);
                    temp = reshape(temp,[],sz(3));
                    ImagePatches(:,count) = mean(temp,1)';
                    count = count +1;
                end
            end
        elseif strcmp(neighorhood_method,'fix-weighted')
            %% weighted window
            Ydata_all_DR = reshape(Ydata_all_DR_org,sz(1),sz(2),sz(3));
            padcam = padarray(Ydata_all_DR,[patchSize patchSize],'symmetric','both');
            
            [m,n] = size(padcam);
            ImagePatches = zeros(sz(3),sz(1)*sz(2));
            tic;
            count = 1;
            for j = patchSize+1:sz(2)+patchSize
                for i = patchSize+1:sz(1)+patchSize
                    temp = padcam(i-(patchSize-1)/2:i+(patchSize-1)/2, j-(patchSize-1)/2:j+(patchSize-1)/2,:);
                    [t1 t2 t3] = size(temp);
                    temp_center = temp((patchSize+1)/2,(patchSize+1)/2,:);
                    temp = reshape(temp,patchSize*patchSize,sz(3));
                    a=ceil(size(temp,1)/2);  %中心像素  temp相当于Yt
                    DD= sum((temp'-temp(a,:)').^2);
                    sigma = mean(DD.^0.5);
                    val = exp(-DD/(1/1*sigma^2));
                    
                    val=val';
                    wi = [];
                    for v= 1:t1*t2
                        wi(v,:) = val(v,:)/(sum(val));
                    end
                    s=wi'*temp;
                    ImagePatches(:,count) = s';
                    
                    count = count +1;
                end
            end
        end
        
        %% feature processing
        if strcmp(neighorhood_method,'noneighbor')
            Ydata_all_DR = Ydata_all_DR_org';
        else
            Ydata_all_DR = reshape(ImagePatches,[],sz(1)*sz(2));
        end
        %% regularization parameters
        for i_lambda = 1:length(lambda_all)
            lambda = lambda_all(i_lambda);
            for i_gamma = 1:length(gamma_all)
                gamma = gamma_all(i_gamma);
                %% classifier
                for i_classifier_type=1:length(classifier_type_all)
                    classifier_type=char(classifier_type_all(i_classifier_type));
                    %% random samples
                    for i_sample_size = 1:length(per_class_all)
                        per_class = per_class_all(i_sample_size);
                        for i_MC = MMiter
                            %--------------------------------------------------------------------------
                            %                         Start MC runs
                            %--------------------------------------------------------------------------
                            tic;
                            fprintf('%s%g%s%g%s%s%s%d\n','IP lambda = ',lambda,' gamma = ',...
                                gamma,' classifier= ',classifier_type,' MC run ', i_MC);
                            %% randomly select the training samples
                            indexes=[];
                            for i_class=1:no_classes
                                temp=find(trainall(2,:)==i_class);
                                if length(temp)<per_class
                                    index_classi=randperm(length(temp),round(length(temp)/2));
                                else
                                    %if mod(per_class,5) == 0
                                    %index_classi=randperm(length(temp),round(length(temp)*per_class));
                                    %else
                                    index_classi=randperm(length(temp),per_class);
                                    
                                    %end
                                end
                                indexes=[indexes temp(index_classi)];
                            end
                            %save('IP_indexes50.mat','indexes');
                            %load IP_indexes50.mat;
                            
                            ens_trainX = Ydata_all_DR(:,trainall(1,indexes));
                            ens_trainY = trainall(2,indexes);
                            
                            testall = trainall;
                            testall(:,indexes) = [];
                            
                            ens_testX = Ydata_all_DR(:,testall(1,:));
                            ens_testY = testall(2,:);
                            %% SGR algorithms
                            if strcmp(classifier_type,'SGR')
                                [ class ] = fun_SGR(ens_trainX,ens_trainY,trainall(1,indexes),Ydata_all_DR,lambda,gamma,mu,sz);
                                class = reshape(class,sz(1)*sz(2),1);
                            elseif strcmp(classifier_type,'***')
                                %% ---------------------
                                %% add you conterparrs here
                                %% ---------------------
                            end
                            seg_results.map = reshape(class,sz(1),sz(2));
                            [seg_results.OA,seg_results.kappa,seg_results.AA,...
                                seg_results.CA]= calcError(testall(2,:)-1, class(testall(1,:))'-1,[1:no_classes]);
                            seg_results.OA
                            seg_results.time = toc;
                            seg_results.p = [];
                            %% output
                            if strcmp(show_CMap,'yes')
                                figure;imagesc(seg_results.map);axis image;
                            end
                            output_folder = sprintf('%s%s%s%s%s',pwd,'\results_IP\',...
                                neighorhood_method,'_',classifier_type);
                            if ~exist(output_folder,'dir')
                                mkdir(output_folder);
                            end
                            confusion_result_path = sprintf('%s%s%d%s%d%s%d%s',output_folder,'\confusionmat_',i_lambda,'_',i_gamma,'_',i_MC,'.mat');
                            save(confusion_result_path,'seg_results');
                        end
                    end
                end
            end
        end
    end
end
