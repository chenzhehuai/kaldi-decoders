. path.sh
set -x
false && \
  {
preinit-lazylm-get-statetable --statetable-out-filename=data_otf/lang_test_tglarge.h3/state_table.0 data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst 2>&1 | tee log/large.1c.log
}
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tglarge_dev_clean_2.amsp.lang_test_tglarge.h3HcCLG.fst/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-faster-mapped --lattice-beam=8.0 --minimize=false --max-active=7000 --min-active=200 --beam=15.0 --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tglarge.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//HCLG.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.2b.log
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tglarge_dev_clean_2.amsp.lang_test_tglarge.h3HcCLG.fst/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-faster-mapped --lattice-beam=8.0 --minimize=false --max-active=7000 --min-active=200 --beam=15.0 --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tglarge.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//HcCLG.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.2a.log
false && \
  {
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --otf-mode=13 --debug-level=1 --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.1  --compose-gc=true --preinit-mode=4 --preinit-para=3 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.1f.log
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tglarge.h3/state_table.2 --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.1  --compose-gc=false --preinit-mode=4 --preinit-para=2 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.1e.b.log
}

nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --otf-mode=13 --debug-level=1 --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.1  --compose-gc=false --preinit-mode=2 --preinit-para=175152530 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.2g.log
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --otf-mode=13 --debug-level=1 --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.1  --compose-gc=false --preinit-mode=0 --preinit-para=175152530 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.2h.log

false && \
  {
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tglarge.h3/state_table.1  --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.0 --compose-gc=false --preinit-mode=4 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.1d.log
awk '$4!=0{print}' data_otf/lang_test_tglarge.h3/state_table.2
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/nnet3/ivectors_dev_clean_2_hires/ivector_online.scp --online-ivector-period=10 --frame-subsampling-factor=3 --frames-per-chunk=140 --extra-left-context=0 --extra-right-context=0 --extra-left-context-initial=0 --extra-right-context-final=0 exp/chain/tdnn1g_sp/decode_tgmed_dev_clean_2.lang_test_tgmed.h3.13.otf.2c.a.conf.latgen-preinit-lazylm-faster-mapped.initall/final.raw "ark,s,cs:apply-cmvn --norm-means=false --norm-vars=false --utt2spk=ark:data/dev_clean_2_hires/split38/1/utt2spk scp:data/dev_clean_2_hires/split38/1/cmvn.scp scp:data/dev_clean_2_hires/split38/1/feats.scp ark:- |" ark:- | latgen-preinit-lazylm-faster-mapped --verbose=6 --otf-mode=13 --debug-level=1 --statetable-out-filename=data_otf/lang_test_tglarge.h3/state_table.2 --statetable-in-filename=data_otf/lang_test_tglarge.h3/state_table.1  --compose-gc=false --preinit-mode=4 --preinit-para=1 --max-active=7000 --min-active=200 --beam=15.0 --lattice-beam=8.0 --minimize=false --acoustic-scale=1.0 --allow-partial=true --word-symbol-table=data_otf/lang_test_tgmed.h3//words.txt exp/chain/tdnn1g_sp/final.mdl data_otf/lang_test_tglarge.h3//left.fst data_otf/lang_test_tglarge.h3//right.fst ark:- "ark:/dev/null" 2>&1 |tee log/large.1e.log
}
