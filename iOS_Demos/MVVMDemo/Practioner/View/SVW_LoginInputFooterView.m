
#import "SVW_LoginInputFooterView.h"


@implementation SVW_LoginInputFooterView

- (void)svw_createViewForView {
    [self addSubview:self.queryBtn];
}

#pragma mark - Layout
- (void)updateConstraints {
    @weakify(self);
    [self.queryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(10);
    }];

    [super updateConstraints];
}

#pragma mark - Getter

- (UIButton *)queryBtn {
    if (!_queryBtn) {
        _queryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_queryBtn setTitle:@"登录遇到问题？" forState:UIControlStateNormal];
        [_queryBtn setTitleColor:SVW_THEMECOLOR forState:UIControlStateNormal];
        _queryBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _queryBtn;
}

@end
