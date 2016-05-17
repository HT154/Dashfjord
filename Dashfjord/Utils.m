//
//  Utils.m
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>

NSString * md5(NSString *string) {
    const char *cStr = string.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

NSString * encodedString(NSString *string) {
    if (string.length == 0) return @"";
    
    CFStringRef static const charsToLeave = CFSTR("-._~"); // RFC 3986 unreserved
    CFStringRef static const charsToEscape = CFSTR(":/?#[]@!$&'()*+,;="); // RFC 3986 reserved
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, charsToLeave, charsToEscape, kCFStringEncodingUTF8);
#pragma clang diagnostic pop
    
    return (__bridge_transfer NSString *)escapedString;
}