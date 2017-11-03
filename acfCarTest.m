dataDir='database/';
addpath(genpath('toolbox/.'));

%% set up opts for training detector (see acfTrain)
opts=acfTrain(); opts.modelDs=[48 48]; opts.modelDsPad=[50 50];
opts.posGtDir=[dataDir 'posGt'];
opts.nWeak=[32 128 512 2048];
opts.posImgDir=[dataDir 'positive']; opts.pJitter=struct('flip',1);
opts.negImgDir=[dataDir 'negative']; opts.pBoost.pTree.fracFtrs=1/16;
opts.pLoad={'squarify',{3,.41}}; opts.name='models/AcfCar';

opts.pPyramid.pChns.pGradMag.colorChn = 1;

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',.01);
detector=acfModify(detector,pModify);

% %% run detector on a sample image (see acfDetect)
% imgNms=bbGt('getFiles',{[dataDir 'test/pos']});
I=imread('database/positive/L_161102143820121.jpg'); tic, [~,bbs]=acfDetect(I,detector); toc
figure(1); im(I); bbApply('draw',bbs); pause(.1);

saveAcfDetector('./models/detector.dat',detector);
% %% test detector and plot roc (see acfTest)
% [miss,~,gt,dt]=acfTest('name',opts.name,'imgDir',[dataDir 'test/pos'],...
%   'gtDir',[dataDir 'test/posGt'],'pLoad',opts.pLoad,...
%   'pModify',pModify,'reapply',0,'show',2);

