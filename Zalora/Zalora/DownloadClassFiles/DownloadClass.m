//
//  DownloadClass.m
//  AeroPlus
//
//  Created by Subin Kurian on 22/09/13.
//
//

#import "DownloadClass.h"
#import <UIKit/UIKit.h>
@implementation DownloadClass
@synthesize isUnderCancelOperation;

#pragma mark Server request
// send get request to server


- (id)SendToServerGet :(NSString *)urlStr :(UIView *)view isBackgroundTask:(BOOL)backgroundTask
{
    self.isBackgroundTask=backgroundTask;   // setting background task flag
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    bool connection=UIAppDelegate.internetAvailable;    // checking internet
    if(connection)
        return [self operationrequest:request withView:view]; // request passing to connecting method
    else
    {
        [self showAlert:@"Internet Error" ];    // internet error warning
        return nil;
    }
}
// sending images to server
-(id)SendToSerVerImage :(NSString *)urlStr imageParamName:(NSString*)serverParam image:(UIImage *)image : (UIView *)view isBackgroundTask:(BOOL)backgroundTask
{
    self.isBackgroundTask=backgroundTask;
    NSMutableString *URL = [NSMutableString stringWithFormat:@"%@",urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    NSData *imageData = UIImageJPEGRepresentation(image, 90);
    NSString *boundary = [NSString stringWithFormat:@"---------------------------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *theBodyData = [NSMutableData data];
    //this appends the image data
    [theBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"1.jpg\"\r\n",serverParam] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[NSData dataWithData:imageData]];
    [theBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:theBodyData];
    bool connection=UIAppDelegate.internetAvailable;    // checking internet
    if(connection)
        return [self operationrequest:request withView:view]; // request passing to connecting method
    else
    {
        [self showAlert:@"Internet Error" ];    // internet error warning
        return nil;
    }
}

// send POST request to server
- (id)SendToServerPost :(NSString *)urlStr data:(id)postData :(UIView *)view isBackgroundTask:(BOOL)backgroundTask
{
    self.isBackgroundTask=backgroundTask;
    NSMutableString *URL = [NSMutableString stringWithFormat:@"%@",urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding] ];
    bool connection=UIAppDelegate.internetAvailable;    // checking internet
    if(connection)
        return [self operationrequest:request withView:view]; // request passing to connecting method
    else
    {
        [self showAlert:@"Internet Error" ];    // internet error warning
        return nil;
    }
   
}

// connecting with server

-(id )operationrequest :(NSMutableURLRequest *)requestOnGo withView:(UIView*)view
{
    @try {
        if(!self.isBackgroundTask)// checking it is a background task or not
        {
            [self performSelectorInBackground:@selector(showindicaterInview:) withObject:view]; // thread for call loader
        }
        else
        {
            self.isBackgroundTask=FALSE;    // making background task flag false for retain default status
        }
   
        __block id result;  // this will be the server obtained result
        dispatch_semaphore_t holdOn = dispatch_semaphore_create(0);
        [NSURLConnection sendAsynchronousRequest:requestOnGo queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
        {
            //  handle error
            result=Nil;
            [self showAlert:@"Server Connection Error"];   //internet error
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ((long)[httpResponse statusCode] >= 200 && (long)[httpResponse statusCode] < 300)// status is success
                {
                    
                    //NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSError *e = nil;
                    result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e]; // Parsing JSON
                    if(e)
                        {
                            [self showAlert:@"Response Error"];    // JOSN ERROR
                            result=Nil;
                        }
        }
        
        else if ((long)[httpResponse statusCode] == 404)// API succeeded but error in response
        {
            NSError *e = nil;
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e]; // Parsing JSON
            
            if(e)
            {
                [self showAlert:@"Response Error" ];    // JOSN ERROR
                result=Nil;
            }
            
        }
        else
            {
                [self showAlert:@"Bad Server request"]; // server error
            }
        }
        dispatch_semaphore_signal(holdOn);
    }];
        dispatch_semaphore_wait(holdOn, DISPATCH_TIME_FOREVER);// waiting for the response finish
        [self performSelectorOnMainThread:@selector(removeIndicater) withObject:Nil waitUntilDone:NO];  // remove loader
        if(self.isUnderCancelOperation) // checking waiting cancel or not
        {
        self.isUnderCancelOperation=FALSE;
        return Nil;
        }
      
        return result;  // returning the obtained result
        
    }
    @catch (NSException * e)
    {
        if(TEST==1) NSLog(@"Exception: %@", e);
            [self showAlert:@"Connection Error" ];// Connection has error
            self.isUnderCancelOperation=FALSE;
            return nil;
    }

}
// stop ongoing request
-(void)cancelOperations
{
    dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
    dispatch_async(mainThreadQueue, ^{
        [self.activityIndicator removeFromSuperview];
        [self.overlayView removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.isUnderCancelOperation=TRUE;
    });
}
#pragma mark Loader

-(void)showindicaterInview :(UIView*)view   //loader showing
{
    
    dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
    dispatch_async(mainThreadQueue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.overlayView = [[UIView alloc] init];
        self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.overlayView.frame = CGRectMake(0, 0, 100, 100);
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.center =self.overlayView.center;
        [self.overlayView addSubview:self.activityIndicator];
        UILabel *lbl=[[UILabel alloc]init];
        lbl.text=@"Loading...";
        lbl.textColor=[UIColor yellowColor];
        [self.overlayView addSubview:lbl];
        [lbl setFrame:CGRectMake(5, 70, 90, 20)];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont fontWithName:@"Cochin-Italic" size:15]];
        [self.activityIndicator startAnimating];
        if(view)
        {
            [view addSubview:self.overlayView];   // Show indicator in top leavel
            self.overlayView.center=view.center;
        }
        else
        {
        UIWindow *window = [UIAppDelegate window];  // fetching the window
        [window addSubview:self.overlayView];   // Show indicator in top leavel
        self.overlayView.center=window.center;
        }
        [[_overlayView layer] setCornerRadius:14];
        [[_overlayView layer] setBorderWidth:3.0];
        [[_overlayView layer] setBorderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.5].CGColor];
    });
}
-(void)removeIndicater  // removing loader
{
    dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
    dispatch_async(mainThreadQueue, ^{
        [self.activityIndicator removeFromSuperview];
        [self.overlayView removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   });
}

// show alert regarding
-(void)showAlert:(NSString*)msg
{
    // dispatch the request in main queue since it could be a background task
    dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();dispatch_async(mainThreadQueue, ^{
    if(msg.length!=0)// checking there is any message to show or not
            [UIAppDelegate.window makeToast:msg];// showing the message in main window
    });
}




#pragma mark - Fast and queue based querry handling

+ (NSString *)getEncodedURLAsUTF8:(NSString *)urlString {
    
    NSString *encodedUrlString = nil;
    
    if (urlString != nil && [NSNull null] != (NSNull *)urlString && [urlString length] > 0) {
        encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return encodedUrlString;
}

+ (NSString *)getDecodedURLAsUTF8:(NSString *)encodedUrlString  {
    
    NSString *decodedUrlString = nil;
    
    if (encodedUrlString != nil && [NSNull null] != (NSNull *)encodedUrlString && [encodedUrlString length] > 0)    {
        decodedUrlString = [encodedUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return decodedUrlString;
}

+ (void)sendRequest:(NSURLRequest *)request
  completionHandler:(void (^)(NSDictionary*, NSError*)) handler {
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setName:@"HTTPRequest queue"];
    [NSURLConnection sendAsynchronousRequest:request  queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)   {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil,error);
            });
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] == 200) { // Sccuess
            NSString *mimeType = [response MIMEType];
            
            if ([mimeType isEqualToString:@"text/json"] ||
                [mimeType isEqualToString:@"application/json"]) {
                
                NSError *parseError = nil;
                
                NSError *e = nil;
                
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                
                
                if (parseError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(nil,parseError);
                    });
                    return;
                }
                
                // RequestLog(@"Response : %@ ",responseDictionary);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(responseDictionary,error);
                });
                return;
                
            }
            else {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:[NSString stringWithFormat:@"UnSupported Mime Type : %@",mimeType] forKey:NSLocalizedDescriptionKey];
                NSError *mimeTypeError = [NSError errorWithDomain:@"com.googleapi.ios" code:800 userInfo:userInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil,mimeTypeError);
                });
                return;
            }
        }
        else {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] forKey:NSLocalizedDescriptionKey];
            NSError *mimeTypeError = [NSError errorWithDomain:@"HTTP Error" code:[httpResponse statusCode] userInfo:userInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil,mimeTypeError);
            });
            return;
        }
        
    }];
}




@end
