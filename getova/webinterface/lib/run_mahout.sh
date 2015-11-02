echo "run MAHOUT"
alias mahout="lib/mahout-distribution-0.9/bin/mahout"
rm -rf data_extractor/seq*
#rm -rf data_extractor/cluster*
rm -rf data_extractor/kmeans
mahout seqdirectory -i data_extractor/rdf/ -o data_extractor/seq_dir/ -ow -c UTF-8 -chunk 64 -xm sequential
mahout seq2sparse -i data_extractor/seq_dir/ -o data_extractor/seq_dir_sparse/ --maxDFPercent 99 --namedVector -ow
mahout kmeans -i data_extractor/seq_dir_sparse/tfidf-vectors/ -o data_extractor/kmeans -c data_extractor/clusters/ -dm org.apache.mahout.common.distance.CosineDistanceMeasure -k 6 -x 100 -ow --clustering
mahout clusterdump -i  data_extractor/kmeans/clusters-*-final -o data_extractor/clusterdump -d data_extractor/seq_dir_sparse/dictionary.file-0 -dt sequencefile  -dm org.apache.mahout.common.distance.CosineDistanceMeasure --pointsDir data_extractor/kmeans/clusteredPoints #--evaluate
mahout clusterdump -i  data_extractor/kmeans/clusters-*-final -o data_extractor/clusterdump.json -of JSON -d data_extractor/seq_dir_sparse/dictionary.file-0 -dt sequencefile  -dm org.apache.mahout.common.distance.CosineDistanceMeasure --pointsDir data_extractor/kmeans/clusteredPoints #--evaluate
mahout clusterdump -i  data_extractor/kmeans/clusters-*-final -o data_extractor/clusterdump.csv -of CSV -d data_extractor/seq_dir_sparse/dictionary.file-0 -dt sequencefile  -dm org.apache.mahout.common.distance.CosineDistanceMeasure --pointsDir data_extractor/kmeans/clusteredPoints #--evaluate



