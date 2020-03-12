inputdir=$1
destination=$2

echo "Running HABLE DCM2NII Conversion"
if [ "`whoami`" = "baymac" ]; then
  for dir in $(find $inputdir -maxdepth 2 -mindepth 2 -type d)
  do

    ID=$(basename $dir)
    echo "ID: $ID"

    for serdir in $(find $dir -mindepth 2 -maxdepth 2 -type d)
    do
      # echo "Serdir: $serdir"
      DOE=$(basename $serdir)
      DOE=${DOE:0:10}
      ID_DOE=$ID"_"$DOE
      sequence_dir=$(basename $(dirname $serdir))

      echo "$ID_DOE --> $sequence_dir"

      mkdir -p $destination/$ID_DOE/$sequence_dir
      dcm2niix -f %i_%p_%s_%t -w 1 -i y -o $destination/$ID_DOE/$sequence_dir/ $serdir
    done
  done

  #delete empty folders
  find $destination -type d -empty -delete
fi
