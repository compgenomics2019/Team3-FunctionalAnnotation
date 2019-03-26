while getopts "i:h" option
do
        case $option in
             i) input=$OPTARG;;
             h) echo "pilerforall.bash -i <Input Directory Name - Only .fasta files>"
                echo "Required Arguments"
                echo "-i Name of Input file directory. All Input files should be in nucleotide fasta format. Script assumes files are only in .fasta format"
                exit 0;
        esac
done

mkdir pilerout
for file in $input*.fasta
  do
  f="$(echo $file | rev | cut -d/ -f1 | rev )"
  #echo $f
  pilercr -in $file -out pilerout/temp_piler_out -quiet -noinfo
  f2=${f%.fasta}.gff
  python pilertogff.py pilerout/temp_piler_out pilerout/$f2
  rm pilerout/temp_piler_out
  done

