//
//  WSmanager.h
//  WebServices
//
//  Created by VishalSharma on 30/03/16.
//  Copyright © 2016 VishalSharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSmanager : NSObject

+(void)editProfileOfUser :(NSString *)userId withEditFieldJson:(NSString *)jsonDataOfUSer;

+(void)uploadImageOfUser:(NSString *)userID image:(NSData* )imageData imageType:(NSString *)imageType imageID:(NSString *)imageID profileType:(NSString *)profileType isuploading:(BOOL)isUpload;

@end
