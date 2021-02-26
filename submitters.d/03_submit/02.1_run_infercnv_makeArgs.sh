#------------------------------------------------------#
# LOCAL VARIABLES
# Input files
#args1=$(echo "\"as.character('${indir}___COUNTS-${i}')\"")  #counts
args1="as.character('${indir}___COUNTS-${i}')"  #counts
args2="as.character('${indir}___CELLS-${i}')" #cells
args3="as.character('${indir}___GENES')" #genes

# Get normal reference
args4=$(grep 'normal' ${indir}___CELLS-${i} | awk '{print $2}' | sort | uniq )
args4="c('${args4//[[:space:]]/','}')"

# output dir
args5="as.character('$outdir')"

# sample and local parameters
args6="as.character('$i')"
args7="as.character('$jobnm1')"
args8="as.character('$BT')"
args9="as.character('$OF')"
#---------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i 'args' -)" )
read -d " " -a  var_array <<< "$var_"
echo "VARIABLES EXPORTED:"
for i in ${var_array[@]}
do
eval temp='$'$i
echo "$i: $temp"
done
unset var_ var_array i temp
#-----------------------------------------------------------------------#

