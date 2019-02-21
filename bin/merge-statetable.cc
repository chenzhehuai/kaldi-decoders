// bin/merge-statetable.cc
//
// Copyright 2018 Zhehuai Chen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "base/kaldi-common.h"
#include "util/common-utils.h"
#include "tree/context-dep.h"
#include "hmm/transition-model.h"
#include "fstext/fstext-lib.h"
#include "decoder/decoder-wrappers.h"
#include "decoder/decodable-matrix.h"
#include "base/timer.h"
#include <fst/script/info.h>

#include "lazylm.h"

int main(int argc, char *argv[]) {
  try {
    using namespace kaldi;
    using namespace fst;
    using fst::SymbolTable;
    using fst::VectorFst;
    using fst::StdArc;

    const char *usage =
        "merge state table for preinit algorithm based on acc\n";

    ParseOptions po(usage);
    Timer timer;
    fst::LazyLMConfig lazylm_config;

    lazylm_config.Register(&po);
    po.Read(argc, argv);

    if (po.NumArgs() < 2) {
      po.PrintUsage();
      exit(1);
    }

    typedef StdArc Arc;
    using Weight = typename Arc::Weight;
    typedef LazyLMComposeFst<Arc>::StateTuple StateTuple;
    typedef std::vector<std::pair<StateTuple, int32>> MapHolder;
    typedef LazyLMComposeFst<Arc>::ComposeFilter ComposeFilter;
    std::string statetable_out_filename = po.GetArg(po.NumArgs());
    MapHolder holder_final;
    for (int32 i=1; i<po.NumArgs(); i++) {
      MapHolder holder;
      std::string statetable_in_filename=po.GetArg(i);
      LoadStateTableFunc<Weight, StateTuple, typename ComposeFilter::FilterState>(holder, statetable_in_filename);
      if (!holder_final.size()) holder_final=holder;
      else {
        KALDI_ASSERT(holder.size() == holder_final.size());
        for (int32 idx=0; idx < holder.size(); idx++) {
          holder_final[idx].second+=holder[idx].second;
        }
      }
    }
    bool binary = lazylm_config.debug_level<=0;
    DumpStateTableFunc<StateTuple>(holder_final, statetable_out_filename, binary);
    KALDI_LOG << "Time taken "<< timer.Elapsed();
  } catch(const std::exception &e) {
    std::cerr << e.what();
    return -1;
  }
}
