#include <string>

#include "llvm/IR/DIBuilder.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/User.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

using namespace std;
using namespace llvm;

uint64_t getAllocSizeInBits(Module &M, Type *Ty) {
    return Ty->isSized()
        ? M.getDataLayout().getTypeAllocSizeInBits(Ty)
        : 0;
}

namespace {
struct SynDbg : public ModulePass {
    static char ID;
    SynDbg() : ModulePass(ID) {}

    virtual bool runOnModule(Module &M) {
        DIBuilder DIB(M);

        unsigned NextLine = 0;

        auto *File = DIB.createFile("NULL", "NULL");
        auto *CU = DIB.createCompileUnit(dwarf::DW_LANG_C, File,
                "MLSAST", /*isOptimized=*/true,"", 0);

        LLVMContext &Ctx = M.getContext();

        for (Function &F : M) {
            auto SPType = DIB.createSubroutineType(
                    DIB.getOrCreateTypeArray(None));

            auto SP = DIB.createFunction(CU, F.getName(), F.getName(),
                    File, NextLine, SPType, NextLine);

            F.setSubprogram(SP);

            for (BasicBlock &BB : F) {
                for (Instruction &I : BB) {
                    I.setDebugLoc(DILocation::get(Ctx, NextLine++, 1,
                                SP));
                }
            }

            DIB.finalizeSubprogram(SP);
        }

        DIB.finalize();

        StringRef DIVersionKey = "Debug Info Version";
        if (!M.getModuleFlag(DIVersionKey)) {
            M.addModuleFlag(Module::Warning, DIVersionKey,
                    DEBUG_METADATA_VERSION);
        }

        return true;
    }

};
}  // end of anonymous namespace

char SynDbg::ID = 0;
static RegisterPass<SynDbg> X(
        "syndbg", "Pass for adding synthetic dbg information.",
        false /* Only looks at CFG */,
        false /* Analysis Pass */
);
