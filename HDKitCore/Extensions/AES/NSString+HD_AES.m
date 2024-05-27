//
//  NSString+HD_AES.m
//  HDKitCore
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "GTMBase64.h"
#import "NSData+HD_AES.h"
#import "NSString+HD_AES.h"

@implementation NSString (HD_AES)

- (NSString *)hd_AES128CBCEncryptWithKey:(NSString *)key iv:(NSString *)iv {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];

    NSData *result = [data hd_AES128CBCEncryptWithKey:key iv:iv];
    if (result && result.length > 0) {
        return [result base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return nil;
}

- (NSString *)hd_AES128CBCDecryptWithKey:(NSString *)key iv:(NSString *)iv {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *result = [data hd_AES128CBCDecryptWithKey:key iv:iv];
    if (result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)hd_threeDESEncryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString *)key {
    const void *vplainText;
    const Byte myIv[8] = {50, 51, 52, 53, 54, 55, 56, 57};
    size_t plainTextBufferSize;

    if (encryptOrDecrypt == kCCDecrypt) {  // 解密
        NSData *EncryptData = [GTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    } else {  // 加密
        NSData *contentData = [self dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger paddingLength = 8 - [contentData length] % 8;
        plainTextBufferSize = [contentData length] + paddingLength;

        vplainText = malloc((plainTextBufferSize + 1) * sizeof(Byte));
        bzero((void *)vplainText, plainTextBufferSize + 1);
        memcpy((void *)vplainText, [contentData bytes], [contentData length]);
    }

    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;

    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    if (key.length < 32) {
        while (key.length < 32) {
            key = [key stringByAppendingString:@"0"];
        }
    } else if (key.length > 32) {
        key = [key substringWithRange:NSMakeRange(0, 32)];
    }
    NSData *data = [GTMBase64 decodeString:key];
    const void *vkey = (const void *)[data bytes];
    CCCryptorStatus ccStatus = CCCrypt(encryptOrDecrypt,
                                       kCCAlgorithm3DES,
                                       0,
                                       vkey,
                                       kCCKeySize3DES,
                                       myIv,
                                       vplainText,
                                       plainTextBufferSize,
                                       (void *)bufferPtr,
                                       bufferPtrSize,
                                       &movedBytes);

    NSString *result;
    if (ccStatus == kCCSuccess) {
        if (encryptOrDecrypt == kCCDecrypt) {
            result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                   length:(NSUInteger)movedBytes]
                                           encoding:NSUTF8StringEncoding];
        } else {
            NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
            result = [self hexStringFromString:[GTMBase64 stringByEncodingData:myData]];
        }

    } else {
        result = nil;
    }

    return result;
}

- (NSString *)hd_AESEncryptWithKey:(NSString *)key {
    NSData *encrypyTextBytes = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultData = [encrypyTextBytes hd_AES256ECBEncryptWithKey:key];
    NSString *base64Result = [resultData base64EncodedStringWithOptions:0];
    return base64Result;
}

- (NSString *)hd_AESDecryptWithKey:(NSString *)key {
    NSData *decryptTextData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *resultText = [[NSString alloc] initWithData:[decryptTextData hd_AES256ECBDecryptWithKey:key] encoding:NSUTF8StringEncoding];
    return [resultText stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
}

#pragma mark - private methods
- (NSString *)hexStringFromString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    // 下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for (int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff];  // 16进制数
        if ([newHexStr length] == 1) {
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
        }
    }
    return hexStr;
}
@end
