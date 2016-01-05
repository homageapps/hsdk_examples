//
//  HFWriterVideo.h
//  HomageSDKFlow
//
//  Created by Aviv Wolf on 25/11/2015.
//  Copyright © 2015 Homage LTD. All rights reserved.
//

#import "HFWObject.h"
#import "HFWriterProtocol.h"

/**
 *  Used to write frames to a video file.
 *  Conforms to HFWriterProtocol.
 */
@interface HFWriterVideo : HFWObject<
    HFWriterProtocol
>

@end
