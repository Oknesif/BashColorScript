
if [ -z $1 ] || [ -z $2 ] 
then 
   echo "Usage: $0 <input directory> <color>"
   exit 0
fi

# Check if given directory is valid
DIR=$(pwd)/$1
if [ ! -d $DIR ]
then
   echo -e "$DIR\nIt is not a directory!"
   exit 0
fi

newcolor=$2

#########################################################
#                                                       #
#                 Normalize colors                      #
#                                                       #
#########################################################

if   [[ "$newcolor" =~ 0x[0-9A-Fa-f]{6} ]]
then
   # The color was given in a hex format, expand it to an array and convert to decimal
   newcolors=($(sed 's/0x\(..\)\(..\)\(..\)/\1 \2 \3/' <<< "$newcolor"))
   newcolors[0]=$(echo "ibase=16;obase=A;${newcolors[0]}" | bc)
   newcolors[1]=$(echo "ibase=16;obase=A;${newcolors[1]}" | bc)
   newcolors[2]=$(echo "ibase=16;obase=A;${newcolors[2]}" | bc)
   # TODO - debugging, delete
   echo "Color entered in hex, components are: R:${newcolors[0]}, G:${newcolors[1]}, B:${newcolors[2]}"
elif [[ "$newcolor" =~ [0-9]{1,3},[0-9]{1,3},[0-9]{1,3} ]]
then
   # Color was entered in decimal, just convert to array
   newcolor=($(sed 's/\(.\{1,3\}\),\(.\{1,3\}\),\(.\{1,3\}\)/\1 \2 \3/' <<< "$newcolor"))
   # TODO - debugging, delete
   echo "Color entered in hex, components are: R:${newcolors[0]}, G:${newcolors[1]}, B:${newcolors[2]}"
else
   echo "Color is in an unknown format. Valid formats are hex: '0xNNNNNN' and dec: 'n,n,n'"
   exit 0
fi


# Compute the scale factors to obtain the new colors from the old by multiplying
conversion[0]=$(echo "${newcolors[0]} / 255" | bc -l )
conversion[1]=$(echo "${newcolors[1]} / 255" | bc -l )
conversion[2]=$(echo "${newcolors[2]} / 255" | bc -l )

# TODO - debug, delete
echo "R: ${colors[0]} => ${newcolors[0]} (${conversion[0]})"
echo "G: ${colors[1]} => ${newcolors[1]} (${conversion[1]})"
echo "B: ${colors[2]} => ${newcolors[2]} (${conversion[2]})"

for i in $1/**/**/*.png; do

   outfile="${i/$1/$1_colored}"

   outpath="$(dirname $i)"
   outpath="${outpath/$1/$1_colored}"

   # echo "Outpath is $outpath"
   echo "Outfile is $outfile"

   mkdir -p $outpath

   convert -color-matrix \
   " ${conversion[0]} 0 0   \
     0 ${conversion[1]} 0   \
     0 0 ${conversion[2]} "   \
     $i $outfile
done
