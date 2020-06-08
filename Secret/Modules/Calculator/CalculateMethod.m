//
//  CalculateMethod.m
//  Secret
//
//  Created by wangjundong on 2017/8/9.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "CalculateMethod.h"

@implementation CalculateMethod


-(instancetype)init
{
    self=[super init];
    if(self)
    {
        _operand1 = 0;
        _operand2 = 0;
        _result = 0;
    }
    return self;
}

-(NSString *)performOperation:(int)input;
{
    
    switch (input) {
        case 201:    //按下“÷”
            if(_operand2!=0)
                _result=_operand1/_operand2;
            else
                return @"错误";
            break;
        case 202:    //按下“×”
            _result=_operand1*_operand2;
            break;
        case 203:    //按下“-”
            _result=_operand1-_operand2;
            break;
        case 204:    //按下“+”
            _result=_operand1+_operand2;
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@",@(_result)];
}


-(void)clear
{
    _operand1 = 0;
    _operand2 = 0;
    _result = 0;
}


@end
