#!/bin/bash
set -x

stage=1
LEX=data/lang
LM=data/lang_test_tgsmall
GRAPH=data_otf/fast_lg_test2

echo "$0 $@"  # Print the command line for logging

[ -f ./path.sh ] && . ./path.sh; # source the path.
. parse_options.sh || exit 1;

if [ $stage -le 0 ]; then

    #keep your lexicon in data/local/dict
    false && \
        {
    local/prepare_dict.sh --stage 3 --nj 30 --cmd "$train_cmd" \
    data/local/lm data/local/lm data/local/dict_nosp
}


#add disambi symbol here
utils/prepare_lang.sh data/local/dict \
"<UNK>" data/local/lang_tmp $LEX

fi

if [ $stage -le 1 ]; then
rm -rf ${GRAPH}
mkdir -p ${GRAPH}
fi



if [ $stage -le 2 ]; then
required="$LEX/L_disambig.fst $LEX/L.fst $LM/G.fst $LEX/phones.txt $LM/words.txt $LEX/words.txt $LEX/phones/silence.csl $LEX/phones/disambig.int"
for f in $required; do
  [ ! -f $f ] && echo "mkgraph.sh: expected $f to exist" && exit 1;
done
if [ `diff $LM/words.txt $LEX/words.txt| wc -l` -gt 0 ];then echo " $LEX/words.txt and  $LM/words.txt diff"; exit 1;fi

#fstdeterminizestar --use-log=true ${LEX}/L_disambig.fst  \
    cat ${LEX}/L_disambig.fst \
    > ${GRAPH}/det.L.fst
#    |  fstrmsymbols $LEX/phones/disambig.int - \
fstisstochastic $GRAPH/det.L.fst

fi

if [ $stage -le 2 ]; then

    cat $GRAPH/det.L.fst \
  | fstminimizeencoded  \
  | fstpush \
  | fstarcsort --sort_type=olabel \
  | fstconvert --fst_type=olabel_lookahead \
    --save_relabel_opairs=${GRAPH}/g.irelabel - > ${GRAPH}/left.fst
fi

if [ $stage -le 3 ]; then
fstrelabel --relabel_ipairs=${GRAPH}/g.irelabel  $LM/G.fst \
  | fstarcsort > ${GRAPH}/right.fst

 fi
if [ $stage -le 4 ]; then
if [  -f "$GRAPH/words.txt" ]; then rm $GRAPH/words.txt ;fi
 
ln -s `pwd`/$LM/words.txt $GRAPH/words.txt
fi
 
if [ $stage -le 5 ]; then
time fstcompose ${GRAPH}/left.fst ${GRAPH}/right.fst \
     $GRAPH/LcG.fst 2>&1 | tee ${GRAPH}/otf.comp
fi
if [ $stage -le 6 ]; then
time  cat  $GRAPH/LcG.fst \
  | fstrmepslocal \
  | fstpushspecial \
  | fstminimizeencoded - \
   $GRAPH/LG.fst #2>&1 | tee -a ${GRAPH}/otf.comp

fi
