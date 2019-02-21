// bin/preinit-lazylm-get-statetable.cc
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
    typedef kaldi::int32 int32;
    using fst::SymbolTable;
    using fst::VectorFst;
    using fst::StdArc;

    const char *usage =
        "get state table for preinit algorithm based on acc\n";

    ParseOptions po(usage);
    Timer timer;
    fst::LazyLMConfig lazylm_config;
    fst::CacheOptions cache_config;
    int gc_limit = 536870912;  // 512MB

    // design for getting statetable
    lazylm_config.otf_mode=13;
    lazylm_config.preinit_mode=2;
    lazylm_config.preinit_para=-1;

    lazylm_config.Register(&po);
    po.Register("compose-gc-limit", &gc_limit,
                "Number of bytes allowed in the composition cache before "
                "garbage collection.");

    po.Read(argc, argv);
    cache_config.gc_limit = gc_limit;

    KALDI_ASSERT(lazylm_config.statetable_out_filename != "");

    if (po.NumArgs() != 2) {
      po.PrintUsage();
      exit(1);
    }

    std::string hcl_in_str = po.GetArg(1),
        g_in_str = po.GetArg(2);

    const bool is_table_hcl =
        ClassifyRspecifier(hcl_in_str, NULL, NULL) != kNoRspecifier;
    const bool is_table_g =
        ClassifyRspecifier(g_in_str, NULL, NULL) != kNoRspecifier;

    if (!is_table_hcl && !is_table_g) {
      // It's important that we initialize decode_fst after loglikes_reader,
      // as it can prevent crashes on systems installed without enough virtual
      // memory.
      // It has to do with what happens on UNIX systems if you call fork() on a
      // large process: the page-table entries are duplicated, which requires a
      // lot of virtual memory.
      fst::Fst<StdArc> *hcl_fst = fst::ReadFstKaldiGeneric(hcl_in_str, true);
      fst::Fst<StdArc> *g_fst = fst::ReadFstKaldiGeneric(g_in_str, true);

      // On-demand composition of HCL and G
      fst::LazyLMComposeFst<StdArc> lazylm(*hcl_fst, *g_fst, lazylm_config, cache_config);
      lazylm.PreInitFST();

      delete hcl_fst;
      delete g_fst;
    } else {
      KALDI_ERR << "The decoding of tables/non-tables and match-type that you "
                << "supplied is not currently supported. Either implement "
                << "this, ask the maintainers to implement it, or call this "
                << "program differently.";
    }

    KALDI_LOG << "Time taken "<< timer.Elapsed();
  } catch(const std::exception &e) {
    std::cerr << e.what();
    return -1;
  }
}
