while read -r line
do
  printf "Downloading: %s .........\n" "$line"
  wget "$line"
  printf "Download finished: %s .........\n" "$line"
done < list.txt
