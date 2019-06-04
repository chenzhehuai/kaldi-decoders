#!/bin/bash
set -x

tscale=1.0
loopscale=1.0
N=2
P=1
stage=0

echo "$0 $@"  # Print the command line for logging

[ -f ./path.sh ] && . ./path.sh; # source the path.
. parse_options.sh || exit 1;

LANG=$1
EXP=$2
GRAPH=$3
KALDI_ROOT=$4

dir=$GRAPH
ilabels=${GRAPH}/ilabels_${N}_${P}
tree=${EXP}/tree
model=${EXP}/final.mdl

#required="$lang/L.fst $lang/G.fst $lang/phones.txt $lang/words.txt $lang/phones/silence.csl $lang/phones/disambig.int $model $tree"
#for f in $required; do
#  [ ! -f $f ] && echo "mkgraph.sh: expected $f to exist" && exit 1;
#done

export PATH=/export/a12/zchen/works/decoder/opendcd/3rdparty/openfst-src/src/bin/:$PATH
export LD_LIBRARY_PATH=/export/a12/zchen/works/decoder/opendcd/3rdparty/openfst-src/src/lib/:/export/a12/zchen/works/decoder/opendcd//3rdparty/local/lib/fst/:$LD_LIBRARY_PATH



if [ $stage -le 0 ]; then
rm -rf ${GRAPH}
mkdir -p ${GRAPH}
fi

if [ $stage -le 1 ]; then

fstdeterminize ${LANG}/L_disambig.fst > ${GRAPH}/det.L.fst

${KALDI_ROOT}/src/fstbin/fstcomposecontext \
  --context-size=$N --central-position=$P \
  --read-disambig-syms=${LANG}/phones/disambig.int \
  --write-disambig-syms=${LANG}/disambig_ilabels_${N}_${P}.int \
  ${GRAPH}/ilabels_${N}_${P} ${GRAPH}/det.L.fst | fstarcsort > ${GRAPH}/CL.fst
fi

if [ $stage -le 2 ]; then
make-ilabel-transducer --write-disambig-syms=$dir/disambig_ilabels_remapped.list \
    $ilabels $tree $model $dir/ilabels.remapped | fstarcsort --sort_type=olabel > $dir/ilabel_map.fst

fsttablecompose $dir/ilabel_map.fst ${GRAPH}/CL.fst | \
     fstdeterminizestar --use-log=true | \
     fstrmsymbols $dir/disambig_ilabels_remapped.list | \
     fstrmepslocal | \
        fstminimizeencoded | fstarcsort | \
        fstconvert --fst_type=const > ${GRAPH}/HCL.fst
fi
if [ $stage -le 2 ]; then
  mkdir $dir/H
  make-h-transducer-fact \
    --transition-scale=$tscale $dir/ilabels.remapped $tree $model \
      ark:$dir/H/H.fsts  || exit 1;
fi




if [ $stage -le 3 ]; then
fstconvert --fst_type=olabel_lookahead \
  --save_relabel_opairs=${GRAPH}/g.irelabel ${GRAPH}/HCL.fst > ${GRAPH}/left.fst

fstrelabel --relabel_ipairs=${GRAPH}/g.irelabel ${LANG}/G.fst \
  | fstarcsort | fstconvert --fst_type=const > ${GRAPH}/right.fst

 fi

if [ $stage -le 4 ]; then
if [  -f "$GRAPH/words.txt" ]; then rm $GRAPH/words.txt ;fi
 ln -s ../../$LANG/words.txt $GRAPH/words.txt
 #awk 'NR==FNR{d[$2]=$1}NR!=FNR{if (d[$2]==""){d[$2]=$2};print $1,d[$2]}' $GRAPH/g.irelabel $LANG/words.txt | sort -k 2n |awk '{print $1,NR-1}' > $GRAPH/words.txt
 #awk 'NR==FNR{d[$1]=$2}NR!=FNR{if (d[$2]==""){d[$2]=$2};print $1,d[$2]}' $GRAPH/g.irelabel $LANG/words.txt | sort -k 2n |awk '{print $1,NR-1}' > $GRAPH/words.txt
 fi

if [ $stage -le 5 ]; then
fstcompose ${GRAPH}/left.fst ${GRAPH}/right.fst \
    > $GRAPH/HcCLG.fst
#    | fstconvert --fst_type=const  \
fi
if [ $stage -le 6 ]; then
  cat  $GRAPH/HcCLG.fst \
  | fstrmepslocal > $GRAPH/HcCLG.fst.re
  cat $GRAPH/HcCLG.fst.re \
  | fstpushspecial \
  | fstminimizeencoded  \
  | fstconvert --fst_type=const \
  > $GRAPH/HCLG.fst

fi
if [ $stage -le 7 ]; then
  fstconvert --fst_type=compact_r_fst_fast_compactor ${GRAPH}/right.fst > ${GRAPH}/right.rfstfast
fi
