//
//  WSmanager.m
//  WebServices
//
//  Created by VishalSharma on 30/03/16.
//  Copyright © 2016 VishalSharma. All rights reserved.
//

#import "WSmanager.h"
#import "XMLDictionary.h"

@implementation WSmanager

+(void)editProfileOfUser :(NSString *)userId withEditFieldJson:(NSString *)jsonDataOfUSer {
    
    NSString * params = [NSString stringWithFormat:@"userId=%@&json=%@",userId, jsonDataOfUSer];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@edit_profile.php",@"Your Saved UR"];
    [self routineWebServiceSyntaxWithParameter:params URL:urlStr andCallback:^(NSDictionary *myJsonResponse){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserProfileEditedSuccesfully" object:myJsonResponse userInfo:nil];
        
        // Or call Your Delegate Here
    }];
}

+(void)uploadImageOfUser:(NSString *)userID image:(NSData* )imageData imageType:(NSString *)imageType imageID:(NSString *)imageID profileType:(NSString *)profileType isuploading:(BOOL)isUpload{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlStr = [NSString stringWithFormat:@"%@upload_user_images.php",@"Your Saved URL"];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    // userId
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userId\"\r\n\r\n%@",userID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // imageType
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageType\"\r\n\r\n%@",imageType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // imageId
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageId\"\r\n\r\n%@",imageID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    if (profileType) {
        
        // isProfilePic
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"isProfilePic\"\r\n\r\n%@",profileType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    
    if (isUpload) {
        
        // upload Image
        [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"newProfilePic.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        
        // send Blank on image on "No Image"
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"\r\n\r\n%@",@""] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [request setHTTPBody:body];
    
    NSData *returnData = [ NSURLConnection sendSynchronousRequest :request returningResponse : nil error : nil ];
    
    NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"returnString: %@",jsonResponse);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageUploadingNotification" object:jsonResponse];
        
    });
}

+(void)routineWebServiceSyntaxWithParameter:(NSString *)parameter URL:(NSString *)urlstr andCallback:(void (^)(NSDictionary *))callback{
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    NSURL * url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    if ([urlstr isEqualToString:@"Check Your URL"])
        [urlRequest setHTTPMethod:@"POST"];
    else
        [urlRequest setHTTPMethod:@"GET"];
    
    
    [urlRequest setHTTPBody:[parameter dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           
                                                           
                                                           if(error == nil)
                                                           {
                                                               if ([urlRequest.URL.absoluteString isEqualToString:@"Check Your URL"]) {
                                                                   // For XML Data.
                                                                   
                                                                   NSDictionary* xmlResponse = [NSDictionary dictionaryWithXMLData:data];
                                                                   callback((NSDictionary*) xmlResponse);
                                                               }
                                                               else{
                                                                   // For Json Data.
                                                                   NSError *aErrorParsing;
                                                                   NSDictionary* aDictJsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&aErrorParsing];
                                                                   // Check for error from YouTube.
                                                                   
                                                                   if ([aDictJsonResponse objectForKey:@"error"])
                                                                       callback([NSDictionary dictionaryWithObject:[[aDictJsonResponse objectForKey:@"error"] valueForKey:@"message"]forKey:@"error"]);
                                                                   
                                                                   else{
                                                                       if (aErrorParsing == nil)
                                                                           callback((NSDictionary*) aDictJsonResponse);
                                                                       
                                                                       else
                                                                           callback([NSDictionary dictionaryWithObject:[aErrorParsing description] forKey:@"error"]);
                                                                   }
                                                                   
                                                               }
                                                           }
                                                           else
                                                               callback([NSDictionary dictionaryWithObject:[error description] forKey:@"error"]);
                                                           
                                                       }];
    
    [dataTask resume];
}
@end
