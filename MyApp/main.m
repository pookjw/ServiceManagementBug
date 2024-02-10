//
//  main.m
//  MyApp
//
//  Created by Jinwoo Kim on 2/10/24.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

int main(int argc, const char * argv[]) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SMAppService *appService = [SMAppService daemonServiceWithPlistName:@"com.pookjw.MyApp.Helper.plist"];
        NSError * _Nullable error = nil;
        
        while (1) {
            if (appService.status != SMAppServiceStatusEnabled) {
                [appService registerAndReturnError:&error];
                
                /*
                 Error Domain=SMAppServiceErrorDomain Code=1 "Operation not permitted" UserInfo={NSLocalizedFailureReason=Operation not permitted}
                 */
                assert(!error);
            }
            
            if (appService.status == SMAppServiceStatusEnabled) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                [appService unregisterWithCompletionHandler:^(NSError * _Nullable error) {
                    assert(!error);
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
            }
            
            // uncomment this to fix
            [NSThread sleepForTimeInterval:2.f];
        }
    });
    
    dispatch_main();
}
