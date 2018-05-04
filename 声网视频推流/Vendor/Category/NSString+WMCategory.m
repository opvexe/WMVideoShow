//
//  NSString+WMCategory.m
//  声网视频推流
//
//  Created by Facebook on 2018/5/3.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "NSString+WMCategory.h"

@implementation NSString (WMCategory)


+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    if (!dic.count) return nil;
    NSArray *keysArray = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableDictionary *newParamers = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"{"];
    
    for (NSString *key in keysArray) {
        [newParamers setValue:[dic valueForKey:key] forKey:key];
        
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newParamers options:kNilOptions error:&parseError];
        NSString* s = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        s = [s stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        s = [s stringByReplacingOccurrencesOfString:@"}" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(s.length-2, 2)];
        s = [s stringByReplacingOccurrencesOfString:@"{" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 2)];
        [string appendString:s];
        [string appendString:@","];
        [newParamers removeAllObjects];
    }
    if(string.length > 1) {
        string = [string stringByReplacingOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(string.length-2, 2)];
        [string appendString:@"}"];
    }
    return string;
}

@end
