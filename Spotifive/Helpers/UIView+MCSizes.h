
#import <UIKit/UIKit.h>

typedef enum {
    MCViewAlignmentTopLeft     = 0,
    MCViewAlignmentTopRight    = 1,
    MCViewAlignmentBottomLeft  = 2,
    MCViewAlignmentBottomRight = 3,

    MCViewAlignmentLeft   = 0,
    MCViewAlignmentRight  = 1,
    MCViewAlignmentTop    = 0,
    MCViewAlignmentBottom = 2
} MCViewAlignment;

@interface UIView (MCSizes)
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

- (void)resizeToView:(UIView *)view;
- (void)setWidth:(CGFloat)width alignment:(MCViewAlignment)alignment;
- (void)setHeight:(CGFloat)height alignment:(MCViewAlignment)alignment;
- (void)setSize:(CGSize)size alignment:(MCViewAlignment)alignment;
@end