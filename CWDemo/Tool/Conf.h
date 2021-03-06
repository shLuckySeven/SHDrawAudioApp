//
//  Conf.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/6.
//  Copyright © 2019年 gsh. All rights reserved.
//

#ifndef Conf_h
#define Conf_h

#define DOCUMENT_PATH                   [NSSearchPathForDirectoriesInDomains(   \
                                            NSDocumentDirectory, NSUserDomainMask, \
                                            YES) objectAtIndex: 0]

#define AUDIO_FOLDER_NAME               @"audios"

#define AUDIO_FOLDER_PATH               [DOCUMENT_PATH stringByAppendingPathComponent:  \
                                            AUDIO_FOLDER_NAME]

//#define CELLIDENTIFIER_AUDIOLISTVC      @"AudioListCellIdentifier"
//#define HEIGHT_AUDIOLIST_TV             70.0f
//
//#define SEGUE_AUDIOLIST2PLAYAUDIO       @"SEGUEAUDIOLIST2PLAYAUDIO"
//
//#define UIImageNamed(x)                 [UIImage imageNamed: (x)]
//
//#define BG_PLAYVOICE_1                  @"playvoice1"
//#define BG_PLAYVOICE_2                  @"playvoice2"
//#define BG_PLAYVOICE_3                  @"playvoice3"

#endif /* Conf_h */

