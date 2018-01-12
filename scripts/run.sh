. path.sh
. cmd.sh

set -x

decode_cmd=$decode_cmd" -l hostname=c*  " #-l hostname=c02
stage=4
dec=/export/a12/zchen/works/decoder/kaldi-decoders/bin/latgen-lazylm-faster-mapped
otf_data=data_otf/lang_test_tgsmall.h/
amdir=exp/chain/tdnn1e_sp/


if [ $stage -le 0 ]; then
#bash script/makeclevel.sh data/lang_test_tgsmall/  exp/tri3b/ data_otf/lang_test_tgsmall $KALDI_ROOT

bash script/makehlevel.sh data/lang_test_tgsmall  exp/chain/tdnn1e_sp/ data_otf/lang_test_tgsmall.h $KALDI_ROOT #exp/chain/tree_sp/graph_tgsmall
exit
fi

if [ $stage -le 1 ]; then
nnet3-am-copy --raw=true $amdir/final.mdl $amdir/final.raw
fi
if [ $stage -le 2 ]; then
nnet3-compute --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 \
    $amdir/final.raw \
"ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" \
ark:- | \
$dec --minimize=false --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --acoustic-scale=1.0 --allow-partial=true \
--word-symbol-table=$otf_data/words.txt  $amdir/final.mdl $otf_data/left.fst $otf_data/right.fst  ark:- ark:/dev/null ark:/tmp/rst.wrd
fi

if [ $stage -le 2 ]; then
#latgen-faster-mapped --minimize=false --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgsmall.h//words.txt exp/chain/tdnn1e_sp//final.mdl exp/chain/tree_sp/graph_tgsmall/HCLG.fst ark:tmp.ark ark:/dev/null ark:/tmp/rst.wrd
/export/a12/zchen/works/decoder/kaldi-decoders/bin/latgen-lazylm-faster-mapped --minimize=false --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgsmall.h//words.txt exp/chain/tdnn1e_sp//final.mdl data_otf/lang_test_tgsmall.h//left.fst data_otf/lang_test_tgsmall.h//right.fst ark:tmp.ark ark:/dev/null ark:/tmp/rst.wrd
fi

if [ $stage -le 3 ]; then
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
otflang=data_otf/lang_test_tgsmall.h/

      steps/nnet3/decode.sh \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --amsplit true \
          $tree_dir/graph_tgsmall/ data/${data}_hires ${dir}/decode_tgsmall_${data}.amsp \
          || exit 1

for otf_mode in 1 2
do
      steps/nnet3/decode.sh \
          --acwt 1.0 --post-decode-acwt 10.0 \
          --extra-left-context $chunk_left_context \
          --extra-right-context $chunk_right_context \
          --extra-left-context-initial 0 \
          --extra-right-context-final 0 \
          --frames-per-chunk $frames_per_chunk \
          --nj $nspk --cmd "$decode_cmd"  --num-threads 1 \
          --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
          --otf_addin " --otf-mode=$otf_mode " \
          --otfdec /export/a12/zchen/works/decoder/kaldi-decoders/bin/latgen-lazylm-faster-mapped \
          $otflang data/${data}_hires ${dir}/decode_tgsmall_${data}.$otf_mode \
          || exit 1
  done

  wait

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
otflang=data_otf/lang_test_tgsmall.h/

false && \
{
      decgraph=$otflang/HcCLG.fst
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
      }&
false && \
    {
      decgraph=$otflang/HCLG.fst
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
      }&

      otfdec=decode-lazylm-faster-mapped
      #otfdec=latgen-lazylm-faster-mapped
#false && \
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
