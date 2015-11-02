mahout clusterdump -i data_extractor/clusters/part-randomSeed -o data_extractor/clusterdump -d data_extractor/seq_dir_sparse/dictionary.file-0 -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 --pointsDir data_extractor/kmeans/clusteredPoints
#data_extractor/clusters-*-final
