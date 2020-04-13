//
//  speex_process.c
//  PitchPerfect
//
//  Created by Alguz on 11/20/19.
//  Copyright © 2019 Andre Rosa. All rights reserved.
//

#include "speex_process.h"
#include <stdio.h>
#include <string.h>
#include "speex/speex_preprocess.h"



SpeexPreprocessState *st;

int Speex_init(int frame_size, int sample_rate)
{

   int i;
   int count=0;
   float f;

   st = speex_preprocess_state_init(frame_size/2, sample_rate);
   i=1;
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DENOISE, &i);
    
   i=0;
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_AGC, &i);
//   i=8000;
   i=sample_rate;
    
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_AGC_LEVEL, &i);
   i=0;
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB, &i);
   f=.0;
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_DECAY, &f);
   f=.0;
   speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_LEVEL, &f);

   return 1;
}

short * Speex_preprocess(short * inbuffer)
{

    short *in = inbuffer;
    
    int vad = speex_preprocess_run(st, in);

    return in;
}

int Speex_destroy()
{
   if(st != NULL)
       speex_preprocess_state_destroy(st);
   st = NULL;
   return 1;
}
