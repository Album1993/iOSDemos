

#import <UIKit/UIKit.h>


@interface SVW_LoginPwdInputTableViewCell : UITableViewCell <SVW_ViewProtocol>

/**
 标题
 */
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

/**
 输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *inputTextFiled;

/**
 操作按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *accessoryButton;

@end
