//
//  JDKeyChainWapper.m
//  WJDStudyLibrary
//
//  Created by wangjundong on 2017/4/27.
//  Copyright © 2017年 wangjundong. All rights reserved.
//
#pragma mark- 说明

#import "JDKeyChainWapper.h"

@implementation JDKeyChainWapper

#pragma mark - Base64编码

#pragma mark 写入

+ (BOOL)addKeyChainWithRSASecKey:(SecKeyRef)SecKey identifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey{
    
    NSMutableDictionary * queryKey = [self getSecKeyRefKeychainQuery:identifier isPublicKey:isPublickey];
    
    [queryKey setObject:(__bridge id)SecKey forKey:(__bridge id)kSecValueRef];
    
    return [self saveQueryKey:queryKey identfier:identifier isPublicKey:isPublickey]?YES:NO;
    
}


+ (SecKeyRef)saveQueryKey:(NSDictionary *)dict identfier:(NSString *)identifier isPublicKey:(BOOL)isPublickey
{
    
    OSStatus status = noErr;
    CFTypeRef result;
    CFDataRef keyData = NULL;
    //如果已经存在,先删除原来的在重新写入
    if (SecItemCopyMatching((__bridge CFDictionaryRef) dict, (CFTypeRef *)&keyData) == noErr) {
        
        [self deleteRASKeyWithIdentifier:identifier isPublicKey:isPublickey];
        status = SecItemAdd((__bridge CFDictionaryRef) dict, &result);
        
        if (status == errSecSuccess) {
            return [self loadSecKeyRefWithIdentifier:identifier isPublicKey:isPublickey];
        }
    }
    
    status = SecItemAdd((__bridge CFDictionaryRef) dict, &result);
    if (status == errSecSuccess) {
        return [self loadSecKeyRefWithIdentifier:identifier isPublicKey:isPublickey];
    }
    
    return nil;
}


+ (BOOL)savePassWordDataWithdIdentifier:(NSString *)identifier data:(id)data accessGroup:(NSString *) accessGroup{
    
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:accessGroup];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    OSStatus status =  SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    if (status != noErr) {
        return NO;
    }
    return YES;
}

+ (BOOL)saveStringWithdIdentifier:(NSString *)identifier data:(NSString *)str;
{
    
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:nil];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:str] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    OSStatus status =  SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    if (status != noErr) {
        return NO;
    }
    return YES;

}

+ (SecKeyRef)loadSecKeyRefWithIdentifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey;
{
    
    NSMutableDictionary *keychainQuery =[self getSecKeyRefKeychainQuery:identifier isPublicKey:isPublickey];
    CFDataRef keyData = NULL;
    //如果已经存在,先删除原来的在重新写入
    if (SecItemCopyMatching((__bridge CFDictionaryRef) keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        return (SecKeyRef)keyData;
    }
    return nil;
}

+ (NSString *)loadStringDataWithIdentifier:(NSString *)identifier
{
    NSString *ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:nil];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {

        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

#pragma mark 删除
+ (void)deletePassWordClassDataWithIdentifier:(NSString *)identifier accessGroup:(NSString *) accessGroup
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:accessGroup];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}
+ (BOOL)deleteRASKeyWithIdentifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey;
{
    OSStatus status = noErr;
    NSMutableDictionary * queryKey = [self getSecKeyRefKeychainQuery:identifier isPublicKey:isPublickey];
    status = SecItemDelete((__bridge CFDictionaryRef) queryKey);
    
    return status ==noErr;
    
}

#pragma mark - 通用方法

+ (NSMutableDictionary *)getSecKeyRefKeychainQuery:(NSString *)identifier isPublicKey:(BOOL)isPublickey{
    
    NSData *d_tag = [NSData dataWithBytes:[identifier UTF8String] length:[identifier length]];
    NSMutableDictionary *publickey =[[NSMutableDictionary alloc]init];
    [publickey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publickey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id) kSecAttrKeyType];
    [publickey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    [publickey setObject:(id)(isPublickey?kSecAttrKeyClassPublic:kSecAttrKeyClassPrivate) forKey:(id)kSecAttrKeyClass];
    [publickey setObject:@YES forKey:(__bridge id) kSecReturnRef];
    
    return publickey;
}


//获取通用密码类型的一个查询体
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)identifier accessGroup:(NSString *)accessGroup
{
    
    
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               (id)kSecClassGenericPassword,(id)kSecClass,
                               identifier, (id)kSecAttrAccount,//一般密码
                               (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
                               nil];
    if (accessGroup) {
        [dic setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
        [dic setObject:identifier forKey:(id)kSecAttrGeneric];
    }
    return dic;
}

//返回需要的 key 字符串
+ (NSString *)base64EncodedFromPEMFormat:(NSString *)PEMFormat
{
    /*
     -----BEGIN RSA PRIVATE KEY-----
     中间是需要的 key 的字符串
     -----END RSA PRIVATE KEY----
     */
    
    PEMFormat = [PEMFormat stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    PEMFormat = [PEMFormat stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    PEMFormat = [PEMFormat stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    PEMFormat = [PEMFormat stringByReplacingOccurrencesOfString:@" "  withString:@""];
    if (![PEMFormat containsString:@"-----"]) {
        return PEMFormat;
    }
    NSString *key = [[PEMFormat componentsSeparatedByString:@"-----"] objectAtIndex:2];
    
    
    
    return key?key:PEMFormat;
}

@end


