//
//  speex_process.h
//  PitchPerfect
//
//  Created by Alguz on 11/20/19.
//  Copyright © 2019 Andre Rosa. All rights reserved.
//

#ifndef speex_process_h
#define speex_process_h




int Speex_init(int frame_size, int sample_rate);

short * Speex_preprocess(short * inbuffer);

int Speex_destroy();


#endif /* speex_process_h */
