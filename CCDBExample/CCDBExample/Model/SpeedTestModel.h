//
//  SpeedTestModel.h
//  CCDBExample
//
//  Created by cmw on 2021/12/13.
//

#import <CCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeedTestModel : CCModel

CC_PROPERTY((nonatomic, assign), NSInteger, compareId)
CC_PROPERTY((nonatomic, strong), NSString *, param1)
CC_PROPERTY((nonatomic, assign), NSInteger, param2)
CC_PROPERTY((nonatomic, assign), CGFloat, param3)
CC_PROPERTY((nonatomic, assign), bool, param4)
CC_PROPERTY((nonatomic, strong), NSString *, param5)
CC_PROPERTY((nonatomic, strong), NSString *, param6)
CC_PROPERTY((nonatomic, strong), NSString *, param7)




@end

NS_ASSUME_NONNULL_END
