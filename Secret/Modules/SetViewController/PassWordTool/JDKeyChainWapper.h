//
//  JDKeyChainWapper.h
//  WJDStudyLibrary
//
//  Created by wangjundong on 2017/4/27.
//  Copyright © 2017年 wangjundong. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface JDKeyChainWapper : NSObject


+ (BOOL)saveStringWithdIdentifier:(NSString *)identifier data:(NSString *)str;
+ (NSString *)loadStringDataWithIdentifier:(NSString *)identifier;

/**
 save username and password to keychain
 
 @param identifier 数据的 id
 @param data 保存的数据
 @param accessGroup 数据的CroupID 需要证书配合,一般设置只为 nil,否则会无法访问 keychain
 
 */
+ (BOOL)savePassWordDataWithdIdentifier:(NSString *)identifier data:(id)data accessGroup:(NSString *) accessGroup;


/**
 delete username and password from keychain
 
 @param identifier 数据的 id
 @param accessGroup 数据的CroupID 需要证书配合,一般设置只为 nil,否则会无法访问 keychain
 
 */
+ (void)deletePassWordClassDataWithIdentifier:(NSString *)identifier accessGroup:(NSString *) accessGroup;


/**
 保存密钥到 keychain
 
 @param SecKey 密钥对象
 @param identifier 保存的 tap
 @param isPublickey 是否是公钥
 @return 返回保存的内容
 */
+ (BOOL)addKeyChainWithRSASecKey:(SecKeyRef)SecKey identifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey;

/**
 删除密钥对
 
 @param identifier 密钥的 tag 标志
 @param isPublickey 是否是公钥
 @return 返回是否删除成功
 */
+ (BOOL)deleteRASKeyWithIdentifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey;

/**
 通过 tag 获取密钥
 
 @param identifier 密钥的 tag
 @param isPublickey 是否是公钥
 @return 取到的密钥
 */
+ (SecKeyRef)loadSecKeyRefWithIdentifier:(NSString *)identifier isPublicKey:(BOOL)isPublickey;



@end
