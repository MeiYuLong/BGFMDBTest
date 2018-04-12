//
//  EditViewController.m
//  BGTest
//
//  Created by 梅YL on 2018/2/7.
//  Copyright © 2018年 梅YL. All rights reserved.
//

#import "EditViewController.h"
#import "PersonModel.h"

@interface EditViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *AgeTextFile;
@property (weak, nonatomic) IBOutlet UITextField *sexTextFiled;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //设置操作过程中不可关闭数据库(即closeDB函数无效),防止数据更新的时候频繁关闭开启数据库.
    bg_setDisableCloseDB(YES);
    
    _nameLabel.text = self.model.name;
    _AgeTextFile.placeholder = [NSString stringWithFormat:@"%ld",self.model.age];
    _AgeTextFile.keyboardType = UIKeyboardTypeNumberPad;
    _AgeTextFile.delegate = self;
    _sexTextFiled.placeholder = [NSString stringWithFormat:@"%@",self.model.sex];
    _sexTextFiled.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    if (textField.tag == 100) {
        self.model.age = [textField.text integerValue];
        
    }else if (textField.tag == 101){
        self.model.sex = textField.text;
    }
    NSString* where1 = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(self.model.name)];
    [self.model bg_updateWhere:where1];
   
}

@end
