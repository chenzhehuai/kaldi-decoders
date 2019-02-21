// bin/lazylm.h

// Copyright 2018 Zhehuai Chen

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#ifndef KALDI_LAZYLM_H_
#define KALDI_LAZYLM_H_

#include "base/kaldi-common.h"
#include "util/common-utils.h"
#include "fstext/fstext-lib.h"
#include "base/timer.h"

namespace fst {
using namespace kaldi;

template<class Arc>
ComposeFst<Arc> TableComposeFst(
    const Fst<Arc> &ifst1, const Fst<Arc> &ifst2,
    const CacheOptions& cache_opts = CacheOptions(),
    const int otf_mode = 1) {
      if (otf_mode==1) {
              typedef Fst<Arc> F;
              typedef SortedMatcher<F> SM;
              typedef TableMatcher<F> TM;
              typedef ArcLookAheadMatcher<SM> LA_SM;
              typedef SequenceComposeFilter<TM, LA_SM> SCF;
              typedef LookAheadComposeFilter<SCF, TM, LA_SM, MATCH_INPUT> LCF;
              typedef PushWeightsComposeFilter<LCF, TM, LA_SM, MATCH_INPUT> PWCF;
              typedef PushLabelsComposeFilter<PWCF, TM, LA_SM, MATCH_INPUT> PWLCF;
              TM* lam1 = new TM(ifst1, MATCH_OUTPUT);
              LA_SM* lam2 = new LA_SM(ifst2, MATCH_INPUT);
              PWLCF* laf = new PWLCF(ifst1, ifst2, lam1, lam2);
              ComposeFstImplOptions<TM, LA_SM, PWLCF> opts(cache_opts, lam1, lam2, laf);
              return ComposeFst<Arc>(ifst1, ifst2, opts);
      }
      else if (otf_mode==2) {
              typedef LookAheadMatcher< StdFst > M;
              typedef AltSequenceComposeFilter<M> SF;
              typedef LookAheadComposeFilter<SF, M>  LF;
              typedef PushWeightsComposeFilter<LF, M> WF;
              typedef PushLabelsComposeFilter<WF, M> ComposeFilter;
              typedef M FstMatcher;
          
              ComposeFstOptions<Arc, FstMatcher, ComposeFilter> opts2(cache_opts);
              return ComposeFst<Arc>(ifst1, ifst2, opts2);
      }
      else if (otf_mode==3) {
              typedef DefaultLookAhead<Arc, MATCH_OUTPUT> LA;
              using FstMatcher = typename LA::FstMatcher;
              using ComposeFilter = typename LA::ComposeFilter;
              ComposeFstOptions<Arc, FstMatcher, ComposeFilter> opts3(cache_opts);
              return ComposeFst<Arc>(ifst1, ifst2, opts3);
      }
      else if (otf_mode==4) {
              typedef DefaultLookAhead<Arc, MATCH_INPUT> LA;
              using FstMatcher = typename LA::FstMatcher;
              using ComposeFilter = typename LA::ComposeFilter;
              ComposeFstOptions<Arc, FstMatcher, ComposeFilter> opts3(cache_opts);
              return ComposeFst<Arc>(ifst1, ifst2, opts3);
      }
      else if (otf_mode==5) {
              return ComposeFst<Arc>(ifst1, ifst2, cache_opts);
      }
      else
      {
              KALDI_ERR << "otf_mode undefined: " << otf_mode << std::endl;
              return ComposeFst<Arc>(ifst1, ifst2, cache_opts);
      }
}
template <class Arc>
void PreInitFSTByIter(Fst<Arc> &fst, int32 depth = -1) {
  using namespace kaldi;
  using StateId = typename Arc::StateId;
  
  Timer timer;
  std::set<StateId> visited;
  std::queue<StateId> queue;
  queue.push(fst.Start());
  int32 cnt=0, cnt2=0;
  std::unordered_map<StateId, int32> levels;
  levels[fst.Start()]=0;
  visited.insert(fst.Start());
  for (StateIterator<Fst<Arc>> siter(fst); !siter.Done(); siter.Next()) {
    cnt++;
    if (cnt > depth && depth!=-1)
      break;
    StateId state=siter.Value();
    fst::ArcIterator<Fst<Arc>> aiter(fst, state);
    for (; !aiter.Done(); aiter.Next()) {
      cnt2++;
    }
  }
  KALDI_VLOG(0) << "preinit_info: " << timer.Elapsed() << " " << depth << " "<<cnt<< " " << cnt2;
}

template <class Arc>
void PreInitFSTBySortedBFS(Fst<Arc> &fst, int32 depth = -1) {
  using namespace kaldi;
  using StateId = typename Arc::StateId;
  
  Timer timer;
  std::unordered_set<StateId> visited;
  std::vector<StateId> next_lev;
  std::vector<StateId> cur_lev;
  int32 cnt=0, cnt2=0;
  visited.insert(fst.Start());
  int32 lev_cnt = 0;
  next_lev.push_back(fst.Start());
  while (next_lev.size() && (depth<0 || lev_cnt++ < depth)) {
    std::swap(next_lev, cur_lev);
    next_lev.clear();
    for (auto state:cur_lev) {
      cnt++;
      fst::ArcIterator<Fst<Arc>> aiter(fst, state);
      for (; !aiter.Done(); aiter.Next()) {
        cnt2++;
        const auto& arc = aiter.Value();
        StateId nextstate = arc.nextstate;
        if (visited.find(nextstate) == visited.end()) {
          visited.insert(nextstate);
          next_lev.push_back(nextstate);
        }
      }
    } // for auto
    std::sort(next_lev.begin(), next_lev.end());
  }
  KALDI_VLOG(0) << "preinit_info: " << timer.Elapsed() << " " << depth << " "<<cnt<< " " << cnt2;
}

template <class Arc>
void PreInitFSTByBFS(Fst<Arc> &fst, int32 depth = -1) {
  using namespace kaldi;
  using StateId = typename Arc::StateId;
  
  Timer timer;
  std::set<StateId> visited;
  std::queue<StateId> queue;
  queue.push(fst.Start());
  int32 cnt=0, cnt2=0;
  std::unordered_map<StateId, int32> levels;
  levels[fst.Start()]=0;
  visited.insert(fst.Start());
  while (!queue.empty()) {
    cnt++;
    StateId state=queue.front();
    queue.pop();
    fst::ArcIterator<Fst<Arc>> aiter(fst, state);
    for (; !aiter.Done(); aiter.Next()) {
      cnt2++;
      const auto& arc = aiter.Value();
      StateId nextstate = arc.nextstate;
      if (visited.find(nextstate) == visited.end()) {
        int32 new_lev = levels[state] + 1;
        levels[nextstate] = new_lev;
        visited.insert(nextstate);
        if (new_lev <= depth || depth == -1) {
          queue.push(nextstate);
        }
      }
    }
  }
  KALDI_VLOG(0) << "preinit_info: " << timer.Elapsed() << " " << depth << " "<<cnt<< " " << cnt2;
}
template <class Arc>
void PreInitFST(Fst<Arc> &decode_fst, int32 preinit_mode, BaseFloat preinit_para) {
  switch (preinit_mode) {
    case 1:
      fst::PreInitFSTByBFS(decode_fst, (int32)preinit_para);
      break;
    case 2:
      fst::PreInitFSTByIter(decode_fst, (int32)preinit_para);
      break;
    case 3:
      fst::PreInitFSTBySortedBFS(decode_fst, (int32)preinit_para);
      break;
    default:
      break;
  }
  return;
}

}  // namespace fst

#endif  // KALDI_LAZYLM_H_
