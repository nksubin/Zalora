//
//  DownloadClass.h
//  AeroPlus
//
//  Created by Subin Kurian on 22/09/13.
//
//

#import <Foundation/Foundation.h>
@interface DownloadClass : NSObject
{
    NSTimer *timer; // timer for acess tocken
}
@property(nonatomic)BOOL isUnderCancelOperation;    // flag for acess tocken
@property(nonatomic,strong)UIView*overlayView;      // view for loader
@property(nonatomic,strong)UIActivityIndicatorView*activityIndicator;   // indicater for loader
@property(nonatomic,assign)BOOL isBackgroundTask;   // flag for background task

- (id)SendToServerGet :(NSString *)urlStr :(UIView *)view isBackgroundTask:(BOOL)backgroundTask; // get request
- (id)SendToServerPost :(NSString *)urlStr data:(id)postData :(UIView *)view isBackgroundTask:(BOOL)backgroundTask; // post request
-(id)SendToSerVerImage :(NSString *)urlStr imageParamName:(NSString*)serverParam image:(UIImage *)image : (UIView *)view isBackgroundTask:(BOOL)backgroundTask; // image request
-(void)cancelOperations;    // operation cancelling



+ (NSString *)getEncodedURLAsUTF8:(NSString *)urlString;    // url encoding
+ (NSString *)getDecodedURLAsUTF8:(NSString *)encodedUrlString; // url decoding


@end
