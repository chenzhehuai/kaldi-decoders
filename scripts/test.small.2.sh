
stage=1
gaf=
otf_data=data_otf/lang_test_tgsmall.h4$gaf/
affix=1g   # affix for the TDNN directory name
amdir=exp/chain/tdnn${affix}_sp/

if [ $stage -le 0 ]; then
bash scripts/makehlevel_4$gaf.sh --stage 3 data/lang_test_tgsmall  exp/chain/tdnn${affix}_sp/ $otf_data $KALDI_ROOT #exp/chain/tree_sp/graph_tgsmall

exit
fi


false && \
  {


nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tgsmall.h3/state_table.2 --statetable-in-filename=data_otf/lang_test_tgsmall.h3/state_table.1  --compose-gc=false --preinit-mode=0 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tgsmall.h3//left.fst data_otf/lang_test_tgsmall.h3//right.fst ark:- "ark:/dev/null" 2>&1 | tee log/small.2a.log
####
}
latgen-preinit-lazylm-faster-mapped --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tgsmall.h3/state_table.2 --statetable-in-filename=data_otf/lang_test_tgsmall.h3/state_table.1  --compose-gc=false --preinit-mode=0 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tgsmall.h3//left.fst data_otf/lang_test_tgsmall.h3//right.fst ark:tmp/tmp.ark "ark:/dev/null" 2>&1 | tee log/small.2b.log
latgen-preinit-lazylm-incremental-mapped --determinize-max-active=50 --determinize-chunk-size=25 --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tgsmall.h3/state_table.2 --statetable-in-filename=data_otf/lang_test_tgsmall.h3/state_table.1  --compose-gc=false --preinit-mode=0 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tgsmall.h3//left.fst data_otf/lang_test_tgsmall.h3//right.fst ark:tmp/tmp.ark "ark:/dev/null" 2>&1 | tee log/small.2c.log
latgen-preinit-lazylm-incremental-fact-mapped --hmm-fst=ark:data_otf/lang_test_tgsmall.h4/H/H.fsts --determinize-max-active=50 --determinize-chunk-size=25 --verbose=6 --otf-mode=13 --debug-level=1  --compose-gc=false --preinit-mode=0 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgsmall.h4//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tgsmall.h4//left.fst data_otf/lang_test_tgsmall.h4//right.fst ark:tmp/tmp.ark "ark:/dev/null" 2>&1 | tee log/small.2d.log
latgen-preinit-lazylm-incremental-fact-mapped --hmm-fst=ark:data_otf/lang_test_tgsmall.h4/H/H.fsts --determinize-max-active=50 --determinize-chunk-size=25 --verbose=6 --otf-mode=13 --debug-level=1  --compose-gc=false --preinit-mode=2 --preinit-para=1000000 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgsmall.h4//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tgsmall.h4//left.fst data_otf/lang_test_tgsmall.h4//right.fst ark:tmp/tmp.ark "ark:/dev/null" 2>&1 | tee log/small.2d2.log
