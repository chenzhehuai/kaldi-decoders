. path.sh
. cmd.sh

set -x

decode_cmd=$decode_cmd" -l hostname=c*  " #-l hostname=c02
stage=4
dec=/export/a12/zchen/works/decoder/kaldi-decoders/bin/latgen-lazylm-faster-mapped
#otf_data=data_otf/lang_test_tgsmall.h3/
otf_data=data_otf/lang_test_tgsmall.h/
amdir=exp/chain/tdnn1e_sp/



if [ $stage -le 0 ]; then
bash script/makehlevel.sh data/lang_test_tgsmall  exp/chain/tdnn1e_sp/ $otf_data $KALDI_ROOT #exp/chain/tree_sp/graph_tgsmall

exit
fi

if [ $stage -le 4 ]; then
chunk_left_context=0
chunk_right_context=0
chunk_width=140,100,160
frames_per_chunk=$(echo $chunk_width | cut -d, -f1)
nnet3_affix=
tree_affix=
tree_dir=exp/chain${nnet3_affix}/tree_sp${tree_affix:+_$tree_affix}
data=dev_clean_2
nspk=$(wc -l <data/${data}_hires/spk2utt)
affix=1e   # affix for the TDNN directory name
dir=exp/chain${nnet3_affix}/tdnn${affix}_sp
otflang=$otf_data

#false && \
{
      decgraph=$otflang/HcCLG.fst
      #decgraph=$otflang/HcCLG2.fst
      steps/nnet3/decode.sh \
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
          $tree_dir/graph_tgsmall/ data/${data}_hires ${dir}/decode_tgsmall_${data}.amsp.`basename $decgraph` \
          || exit 1
      }

      otfdec=decode-lazylm-faster-mapped
      #otfdec=latgen-lazylm-faster-mapped
false && \
    {
for dec_conf in conf/otf.1a.conf #conf/otf.1b.conf 
do
    for otf_mode in 3 2
    do
    {
      steps/nnet3/decode.sh \
          --config $dec_conf \
          --stage 3 \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --otf_addin " --otf-mode=$otf_mode " \
          --otfdec /export/a12/zchen/works/decoder/kaldi-decoders/bin/$otfdec \
          $otflang data/${data}_hires ${dir}/decode_tgsmall_${data}.$otf_mode.`basename $dec_conf`.$otfdec \
          || exit 1
      }&
  done
  done
}

  wait

fi
