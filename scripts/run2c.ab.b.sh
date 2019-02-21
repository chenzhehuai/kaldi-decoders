. path.sh
. cmd.sh

set -x
#otfdec=decode-lazylm-faster-mapped
otfdec=latgen-preinit-lazylm-faster-mapped
decode_cmd=$decode_cmd" -l hostname=c*  " #-l hostname=c02
stage=6
otf_data=data_otf/lang_test_tgsmall.h3/
#otf_data=data_otf/lang_test_tgsmall.h/
affix=1g   # affix for the TDNN directory name
amdir=exp/chain/tdnn${affix}_sp/



if [ $stage -le 0 ]; then
bash scripts/makehlevel_3.sh data/lang_test_tgsmall  exp/chain/tdnn${affix}_sp/ $otf_data $KALDI_ROOT #exp/chain/tree_sp/graph_tgsmall

exit
fi

chunk_left_context=0
chunk_right_context=0
chunk_width=140,100,160
frames_per_chunk=$(echo $chunk_width | cut -d, -f1)
nnet3_affix=
tree_affix=
tree_dir=exp/chain${nnet3_affix}/tree_sp${tree_affix:+_$tree_affix}
data=dev_clean_2
nspk=$(wc -l <data/${data}_hires/spk2utt)
dir=exp/chain${nnet3_affix}/tdnn${affix}_sp
otflang=$otf_data


if [ $stage -le 4 ]; then
false && \
{
      decgraph=$otflang/HcCLG.fst
      #decgraph=$otflang/HcCLG2.fst
      scripts/decode.otf.sh \
          --decgraph $decgraph \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --amsplit true \
          $tree_dir/graph_tgsmall/ data/${data}_hires ${dir}/decode_tgsmall_${data}.amsp.`basename $otflang``basename $decgraph` \
          || exit 1
      }
false && \
{
      decgraph=$otflang/HCLG.fst
      #decgraph=$otflang/HcCLG2.fst
      scripts/decode.otf.sh \
          --decgraph $decgraph \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --amsplit true \
          $tree_dir/graph_tgsmall/ data/${data}_hires ${dir}/decode_tgsmall_${data}.amsp.`basename $otflang``basename $decgraph` \
          || exit 1
      }&


#false && \
    {
for dec_conf in conf/otf.2b.c.conf conf/otf.2b.b.conf conf/otf.2b.a.conf #conf/otf.2a.a.conf conf/otf.2a.b.conf conf/otf.2a.c.conf conf/otf.2a.d.conf conf/otf.2a.e.conf
do
    for otf_mode in 3 #2
    do
    {
      scripts/decode.otf.sh \
          --config $dec_conf \
          --stage 0 \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --otf_addin " --otf-mode=$otf_mode " \
          --otfdec $otfdec \
          $otflang data/${data}_hires ${dir}/decode_tgsmall_${data}.`basename $otflang`.$otf_mode.`basename $dec_conf`.$otfdec \
          || exit 1
      }
  done
done
}

  wait

fi

if [ $stage -le 5 ]; then
preinit-lazylm-get-statetable --debug-level=1 --statetable-out-filename=$otflang/state_table.0  $otflang/left.fst $otflang/right.fst 
fi

if [ $stage -le 6 ]; then

for dec_conf in conf/otf.2c.b.conf #conf/otf.2c.a.conf
do
    for otf_mode in 13 #2
    do
    {
      dec_dir=${dir}/decode_tgsmall_${data}.`basename $otflang`.$otf_mode.`basename $dec_conf`.$otfdec.initall

      scripts/decode.otf.sh \
          --config $dec_conf \
          --stage 0 \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --otf_addin " --otf-mode=$otf_mode --debug-level=1 --statetable-in-filename=$dec_dir/state_table.1 " \
          --otfdec $otfdec \
          --init_statetable  $otflang/state_table.0 \
          --init_all 1 \
          $otflang data/${data}_hires $dec_dir \
          || exit 1
      }
  done
done

fi
