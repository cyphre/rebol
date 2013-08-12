#include "reb-c.h"
#include "reb-ext.h"

const char *init_block =
    "REBOL [\n"
        "Title: {Example Extension Module}\n"
        "Name: example\n"
        "Type: module\n"
        "Exports: [add-mul]\n"
    "]\n"
    "add-mul: command [{Add and multiply integers.} a b c]\n"
;

RXIEXT const char *RX_Init(int opts, RL_LIB *lib) {
    RXI = lib;
    if (!CHECK_STRUCT_ALIGN) exit(100);
    return 0;
}

RXIEXT int RX_Call(int cmd, RXIFRM *frm) {
    RXA_INT64(frm, 1) =
        (RXA_INT64(frm, 1) + RXA_INT64(frm, 2)) *
        RXA_INT64(frm, 3);
    return RXR_VALUE;
}
