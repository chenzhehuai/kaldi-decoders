set -o pipefail

tscale=1.0
loopscale=0.1

remove_oov=false

for x in `seq 4`; do
  [ "$1" == "--mono" -o "$1" == "--left-biphone" -o "$1" == "--quinphone" ] && shift && \
    echo "WARNING: the --mono, --left-biphone and --quinphone options are now deprecated and ignored."
  [ "$1" == "--remove-oov" ] && remove_oov=true && shift;
  [ "$1" == "--transition-scale" ] && tscale=$2 && shift 2;
  [ "$1" == "--self-loop-scale" ] && loopscale=$2 && shift 2;
done

if [ $# != 3 ]; then
   echo "Usage: utils/mkgraph.sh [options] <lang-dir> <model-dir> <graphdir>"
   echo "e.g.: utils/mkgraph.sh data/lang_test exp/tri1/ exp/tri1/graph"
   echo " Options:"
   echo " --remove-oov       #  If true, any paths containing the OOV symbol (obtained from oov.int"
   echo "                    #  in the lang directory) are removed from the G.fst during compilation."
   echo " --transition-scale #  Scaling factor on transition probabilities."
   echo " --self-loop-scale  #  Please see: http://kaldi-asr.org/doc/hmm.html#hmm_scale."
   echo "Note: the --mono, --left-biphone and --quinphone options are now deprecated"
   echo "and will be ignored."
   exit 1;
fi

if [ -f path.sh ]; then . ./path.sh; fi

lang=$1
tree=$2/tree
model=$2/final.mdl
dir=$3

mkdir -p $dir

N=$(tree-info $tree | grep "context-width" | cut -d' ' -f2) || { echo "Error when getting context-width"; exit 1; }
P=$(tree-info $tree | grep "central-position" | cut -d' ' -f2) || { echo "Error when getting central-position"; exit 1; }

[[ -f $2/frame_subsampling_factor && $loopscale != 1.0 ]] && \
  echo "$0: WARNING: chain models need '--self-loop-scale 1.0'";

mkdir -p $lang/tmp

set -ex 

#---------------

fstdeterminize ${lang}/L_disambig.fst | fstarcsort > ${dir}/det.L.fst

#---------------

fstcomposecontext \
    --context-size=$N --central-position=$P \
    --read-disambig-syms=${lang}/phones/disambig.int \
    --write-disambig-syms=${lang}/disambig_ilabels_${N}_${P}.int \
    ${dir}/ilabels_${N}_${P} ${dir}/det.L.fst | \
    fstarcsort > ${dir}/CL.fst

# #---------------

make-h-transducer \
    --disambig-syms-out=${dir}/h.disambig.int \
    --transition-scale=$tscale \
    ${dir}/ilabels_${N}_${P} \
    ${tree} \
    ${model} > ${dir}/Ha.fst

cat ${dir}/Ha.fst > ${dir}/det.Ha.fst

#---------------

fstconvert \
     --fst_type=ilabel_lookahead \
     --save_relabel_ipairs=${dir}/h.orelabel ${dir}/CL.fst | \
     fstarcsort --sort_type=ilabel > ${dir}/la.CL.fst
    
fstrelabel --relabel_opairs=${dir}/h.orelabel ${dir}/det.Ha.fst | \
     fstarcsort --sort_type=olabel | \
     fstcompose - ${dir}/la.CL.fst > ${dir}/det.HaCL.fst

#---------------

fstdeterminize ${dir}/det.HaCL.fst | \
    fstrmsymbols ${dir}/h.disambig.int | \
    fstrmepslocal | \
    fstpushspecial | \
    fstminimizeencoded | \
    add-self-loops --self-loop-scale=$loopscale --reorder=true ${model} - | \
    fstarcsort --sort_type=olabel | \
    fstconvert --fst_type=const > ${dir}/HCL.fst

#-----------------------------

fstconvert --fst_type=olabel_lookahead --save_relabel_opairs=${dir}/g.irelabel ${dir}/HCL.fst > ${dir}/HCLr.fst
fstrelabel --relabel_ipairs=${dir}/g.irelabel ${lang}/G.fst | \
    fstarcsort | \
    fstconvert --fst_type=const > ${dir}/Gr.fst

fstcompose ${dir}/HCLr.fst ${dir}/Gr.fst | \
    fstconvert --fst_type=const > ${dir}/HCLrGr.fst

cp $lang/words.txt $dir/ || exit 1;
mkdir -p $dir/phones
cp $lang/phones/word_boundary.* $dir/phones/ 2>/dev/null # might be needed for ctm scoring,
cp $lang/phones/align_lexicon.* $dir/phones/ 2>/dev/null # might be needed for ctm scoring,
cp $lang/phones/optional_silence.* $dir/phones/ 2>/dev/null # might be needed for analyzing alignments.
    # but ignore the error if it's not there.

cp $lang/phones/disambig.{txt,int} $dir/phones/ 2> /dev/null
cp $lang/phones/silence.csl $dir/phones/ || exit 1;
cp $lang/phones.txt $dir/ 2> /dev/null # ignore the error if it's not there.

# to make const fst:
# fstconvert --fst_type=const $dir/HCLG.fst $dir/HCLG_c.fst
am-info --print-args=false $model | grep pdfs | awk '{print $NF}' > $dir/num_pdfs


#I construct G this way:

 cat $dir/text.filtered.txt.arpa |
        grep -v '<s> <s>' | \
        grep -v '</s> <s>' | \
        grep -v '</s> </s>' | \
        arpa2fst --disambig-symbol='#0' --read-symbol-table=$syms - - | \
        fstrmepsilon | \
        fstdeterminizestar --use-log=true | \
        fstminimizeencoded | \
        fstarcsort --sort_type=ilabel > $dir/G.fst
