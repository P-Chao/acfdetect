function saveAcfDetector(path, detector)

% Usage example: saveAcfDetector('acfCarDetector.dat',detector)

fid = fopen(path, 'w+');
fwrite(fid, size(detector.clf.fids), 'uint32');
fwrite(fid, detector.clf.fids, 'uint32');
fwrite(fid, detector.clf.thrs, 'single');
fwrite(fid, detector.clf.child, 'uint32');
fwrite(fid, detector.clf.hs, 'single');
fwrite(fid, detector.clf.weights, 'single');
fwrite(fid, detector.clf.depth, 'uint32');
fwrite(fid, detector.clf.treeDepth, 'uint32');
fwrite(fid, detector.opts.stride, 'uint32');
fwrite(fid, detector.opts.cascThr, 'int32');
fwrite(fid, int32(detector.opts.modelDs), 'int32');
fwrite(fid, int32(detector.opts.modelDsPad), 'int32');

fclose(fid);