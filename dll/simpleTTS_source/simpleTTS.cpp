/***********************************************************************
**
**  REBOL Invasion 3.0
**
**  simpleTTS REBOL Extension
**	J. Colineau 2009-2010
**
***********************************************************************/

#define ODD_INT_64

// modif JC 6/11/2010
#define REB_EXT 
#define TO_WIN32

#include "reb-c.h"
#include "reb-ext.h"

// modif JC: 
#include "reb-args.h"
#include "reb-device.h"
#include "reb-event.h"

#include "reb-lib.h"

#include "StdAfx.h"
#include <sapi.h>


enum command_nums {
	CMD_TTS,
};

const char *init_block =
    "REBOL [\n"
		" title: {Simple TTS extension}\n"
		" type: module\n"
		" options: [extension]\n"
	"]\n"
	"export TTS: command [{simple Text To Speak} str [string!]]\n"
;


u32 *word_ids = 0; // used to hold word identifiers
    
RL_LIB *RL;


RXIEXT const char *RX_Init(int opts, RL_LIB *lib) {
	RL = lib;
//	if ((sizeof(RXIARG) != 8 ) || (lib->version != RL_VERSION))  //RXI_VERSION) 
//		return 0;
	return init_block;
}

RXIEXT int RX_Quit(int opts) {
	return 0;
}

RXIEXT int RX_Call(int cmd, RXIFRM *frm, void *data) {
	switch (cmd) {

	case CMD_TTS:
	{
	
    if (FAILED(::CoInitialize(NULL)))
        return RXR_FALSE;

	ISpVoice * pVoice = NULL;


	REBCHR *s = (REBCHR *)RL_MAKE_STRING(1000,true);
	REBSER *ss = (REBSER *)RXA_SERIES(frm, 1);
	i32 idx = RXA_INDEX(frm, 1);
	RL_GET_STRING(ss,idx,(void **)&s);

	char *a = (char *)s;
	
	
    PWSTR phrase;
	// conversion char en WCHAR
    int count = 0;
    count = MultiByteToWideChar(CP_UTF8, 0, a , strlen(a) , NULL , 0);  
    if(count > 0) { 
      phrase = SysAllocStringLen(0, count);
      MultiByteToWideChar(CP_UTF8, 0, a , strlen(a) , phrase , count);
    }

    HRESULT hr = CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void **)&pVoice);
    if( SUCCEEDED( hr ) )
    {
		hr = pVoice->Speak(phrase, SPF_IS_XML, NULL);
        pVoice->Release();
        pVoice = NULL;
    }
    ::CoUninitialize();
	
	SysFreeString(phrase);
	
		}
		break;

	default:
		return RXR_NO_COMMAND;
	}

	return RXR_TRUE;
}


