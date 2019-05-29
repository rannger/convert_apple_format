//
//  main.m
//  convert_apple_format
//
//  Created by liangxuan on 2019/5/29.
//  Copyright © 2019 liangxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KSCrash.h>
#import <KSCrashReportFilterAppleFmt.h>

static void convertFile(const char* filePath) {
    NSString *srcFilePath = [NSString stringWithUTF8String:filePath];
    
    NSData *myJSON = [NSData dataWithContentsOfFile:srcFilePath];
    
    NSError* localError = nil;
    
    NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:myJSON options:0 error:&localError];
    
    if(localError != nil)
        return ;

    id filter = [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicatedSideBySide];
    
    NSArray *reports = @[parsedJSON];
    [filter filterReports:reports
             onCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
                 if(error != nil) return;
                 if(completed) {
                     NSString *contents = [filteredReports objectAtIndex:0];
                     NSData* data = [contents dataUsingEncoding:NSUTF8StringEncoding];
                     char* buf = (char*)(data.bytes);
                     long size = data.length;
                     while (1) {
                         const long ret = write(STDOUT_FILENO, (void*)buf, size);
                         if (ret < 0) return;
                         if (ret == size) return;
                         if (ret < size) {
                             size -= ret;
                             buf += ret;
                         }
                     }
                 }
             }];
}

static void printUsage(void) {
    char* usage = "Usage: convert_apple_format report.json";
    printf("%s\n",usage);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        if (argc<2) {
            printUsage();
            exit(-1);
        }
        for (int index = 1; index<argc; ++index) {
            convertFile(argv[index]);
        }
    }
    return 0;
}
