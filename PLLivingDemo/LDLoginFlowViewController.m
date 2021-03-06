//
//  LDLoginFlowViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/28.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLoginFlowViewController.h"
#import "UIImage+FixOrientation.h"
#import "LDLobbyViewController.h"
#import "LDServer.h"
#import "LDUser.h"
#import "LDLivingConfiguration.h"

@interface LDLoginFlowViewController ()
@property (nonatomic, weak) LDLoginFlowViewController *parent;
- (instancetype)initWithTitle:(NSString *)title withParent:(LDLoginFlowViewController *)parent;
@end

@interface _LDLoginInputPhoneNumberViewController : LDLoginFlowViewController
@property (nonatomic, strong) UITextField *phoneNumber;
@property (nonatomic, strong) UIButton *sendButton;
@end

@interface _LDLoginConfirmationViewController : LDLoginFlowViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) UITextField *confirmationField;
@property (nonatomic, strong) UIButton *sendButton;
@end

@interface _LDLoginPerfectInformation : LDLoginFlowViewController <UINavigationControllerDelegate,
                                                                   UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSString *uploadToken;
@property (nonatomic, strong) NSString *iconURL;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *resetIconButton;
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) UIButton *createUserButton;

- (instancetype)initWithTitle:(NSString *)title withUploadToken:(NSString *)uploadToken withParent:(LDLoginFlowViewController *)parent;

@end

@implementation LDLoginFlowViewController

- (instancetype)initWithTitle:(NSString *)title withParent:(LDLoginFlowViewController *)parent
{
    if (self = [self init]) {
        self.title = title;
        _parent = parent;
    }
    return self;
}

+ (instancetype)loginFlowViewController
{
    return [[_LDLoginInputPhoneNumberViewController alloc] initWithTitle:LDString("enter-phone-number")
                                                              withParent:nil];
}

- (instancetype)rootFlowViewController
{
    LDLoginFlowViewController *vc = self;
    while (vc.parent) {
        vc = vc.parent;
    }
    return vc;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.title;
        titleLabel.textColor = kcolTextButton;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [titleLabel sizeToFit];
        titleLabel;
    });
    
    if ([self isKindOfClass:[_LDLoginInputPhoneNumberViewController class]]) {
        self.navigationItem.leftBarButtonItem = ({
            UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] init];
            [closeButton setImage:[UIImage imageNamed:@"icon-close"]];
            [closeButton setTintColor:kcolCloseButtonIcon];
            [closeButton setTarget:self];
            [closeButton setAction:@selector(_onPressedCloseButton:)];
            closeButton;
        });
    } else {
        self.navigationItem.leftBarButtonItem = ({
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
            [backButton setImage:[UIImage imageNamed:@"arrows-left"]];
            [backButton setTintColor:kcolCloseButtonIcon];
            [backButton setTarget:self];
            [backButton setAction:@selector(_onPressedBackButton:)];
            backButton;
        });
    }
}

- (void)_onPressedCloseButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_onPressedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)_createButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.layer.cornerRadius = 25;
    button.layer.borderWidth = 1;
    [self _setEnable:YES withButton:button];
    return button;
}

- (void)_setEnable:(BOOL)enable withButton:(UIButton *)button
{
    UIColor *color = enable ? kcolButtonEnable : kcolButtonNotEnable;
    [button setTitleColor:color forState:UIControlStateNormal];
    button.layer.borderColor = color.CGColor;
    button.enabled = enable;
}

@end

@implementation _LDLoginInputPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.phoneNumber = ({
        UITextField *field = [[UITextField alloc] init];
        [self.view addSubview:field];
        field.textColor = kcolTextButton;
        field.tintColor = kcolTextButton;
        field.font = [UIFont systemFontOfSize:24];
        field.textAlignment = NSTextAlignmentCenter;
        field.keyboardType = UIKeyboardTypeNumberPad;
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(142);
            make.left.and.right.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
        field;
    });
    
    self.sendButton = ({
        UIButton *button = [self _createButton];
        [self.view addSubview:button];
        [button setTitle:LDString("send-confirmation-code") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumber).with.offset(76);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(220, 50));
        }];
        button;
    });
    
    [self.phoneNumber addTarget:self action:@selector(_onPhoneNumberChanged)
               forControlEvents:UIControlEventEditingChanged];
    [self _setEnable:NO withButton:self.sendButton];
    
    [self.sendButton addTarget:self action:@selector(_onPressedSend:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.phoneNumber becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.phoneNumber resignFirstResponder];
}

- (void)_onPhoneNumberChanged
{
    BOOL allowSend = self.phoneNumber.text.length > 0;
    for (NSUInteger i = 0; i < self.phoneNumber.text.length; ++ i) {
        unichar c = [self.phoneNumber.text characterAtIndex:i];
        if (c > '9' || c < '0') {
            allowSend = NO;
            break;
        }
    }
    [self _setEnable:allowSend withButton:self.sendButton];
}

- (void)_onPressedSend:(id)sender
{
    [self _setEnable:NO withButton:self.sendButton];
    self.phoneNumber.enabled = NO;
    
    [[LDServer sharedServer] requestMobileCaptchaWithPhoneNumber:self.phoneNumber.text withComplete:^{
        
        _LDLoginConfirmationViewController *viewController = [[_LDLoginConfirmationViewController alloc] initWithTitle:LDString("enter-confirmation-code") withParent:self];
        [self.navigationController pushViewController:viewController animated:YES];
        
        viewController.phoneNumber = self.phoneNumber.text;
        
        [self _setEnable:YES withButton:self.sendButton];
        self.phoneNumber.enabled = YES;
        
    } withFail:^(NSError * _Nullable responseError) {
        
        [self _setEnable:YES withButton:self.sendButton];
        self.phoneNumber.enabled = YES;
    }];
}

@end

@implementation _LDLoginConfirmationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.confirmationField = ({
        UITextField *field = [[UITextField alloc] init];
        [self.view addSubview:field];
        field.textColor = kcolTextButton;
        field.tintColor = kcolTextButton;
        field.font = [UIFont systemFontOfSize:24];
        field.textAlignment = NSTextAlignmentCenter;
        field.keyboardType = UIKeyboardTypeNumberPad;
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(142);
            make.left.and.right.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
        field;
    });
    
    self.sendButton = ({
        UIButton *button = [self _createButton];
        [self.view addSubview:button];
        [button setTitle:LDString("send-confirmation-code") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.confirmationField).with.offset(76);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(220, 50));
        }];
        button;
    });
    
    [self.confirmationField addTarget:self action:@selector(_onConfirmationFieldChanged)
               forControlEvents:UIControlEventEditingChanged];
    [self.confirmationField setDelegate:self];
    [self _setEnable:NO withButton:self.sendButton];
    
    [self.sendButton addTarget:self action:@selector(_onPressedSend:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.confirmationField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.confirmationField resignFirstResponder];
}

- (void)_onPressedSend:(id)sender
{
    self.sendButton.enabled = NO;
    
    [[LDServer sharedServer] postMobileCaptcha:self.confirmationField.text withPhoneNumber:self.phoneNumber withComplete:^(NSString *uploadToken) {
        
        self.sendButton.enabled = YES;
        
        if (uploadToken) {
            UIViewController *viewController = [[_LDLoginPerfectInformation alloc] initWithTitle:LDString("perfect-information") withUploadToken:uploadToken withParent:self];
            [self.navigationController pushViewController:viewController animated:YES];
            
        } else {
            [self.view makeToast:LDString("confirm-fail") duration:1.2 position:CSToastPositionCenter];
        }
    } withFail:^(NSError * _Nullable responseError) {
        self.sendButton.enabled = YES;
    }];
}

- (void)_onConfirmationFieldChanged
{
    BOOL allowSend = self.confirmationField.text.length == 4;
    if (allowSend) {
        for (NSUInteger i = 0; i < self.confirmationField.text.length; ++ i) {
            unichar c = [self.confirmationField.text characterAtIndex:i];
            if (c > '9' || c < '0') {
                allowSend = NO;
                break;
            }
        }
    }
    [self _setEnable:allowSend withButton:self.sendButton];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [textField.text length] + [string length] - range.length <= 4;
}

@end

@implementation _LDLoginPerfectInformation

- (instancetype)initWithTitle:(NSString *)title withUploadToken:(NSString *)uploadToken withParent:(LDLoginFlowViewController *)parent
{
    if (self = [self initWithTitle:title withParent:parent]) {
        _uploadToken = uploadToken;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *iconContainer = ({
        UIView *container = [[UIView alloc] init];
        [self.view addSubview:container];
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(80);
            make.left.equalTo(self.view).with.offset(30);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        container.layer.cornerRadius = 40;
        container.layer.masksToBounds = YES;
        container.backgroundColor = kcolIconBackground;
        container;
    });
    
    self.iconImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"user"];
        [iconContainer addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(iconContainer);
        }];
        imageView;
    });
    
    self.resetIconButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:button];
        [button setImage:[UIImage imageNamed:@"Shape"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(iconContainer);
        }];
        button;
    });
    
    self.userNameField = ({
        UITextField *field = [[UITextField alloc] init];
        [self.view addSubview:field];
        field.placeholder = LDString("user-name");
        field.textColor = [UIColor blackColor];
        field.tintColor = [UIColor blackColor];
        field.font = [UIFont systemFontOfSize:14];
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(101);
            make.left.equalTo(iconContainer.mas_right).with.offset(32);
            make.right.equalTo(self.view).with.offset(-44);
        }];
        field;
    });
    
    ({
        UIView *line = [[UIView alloc] init];
        [self.view addSubview:line];
        line.backgroundColor = [UIColor blackColor];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(138);
            make.left.equalTo(iconContainer.mas_right).with.offset(32);
            make.right.equalTo(self.view).with.offset(-44);
            make.height.mas_equalTo(1);
        }];
    });
    
    self.createUserButton = ({
        UIButton *button = [self _createButton];
        [self.view addSubview:button];
        [button setTitle:LDString("create-account") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_onPressedCreateAccount:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(194);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(220, 50));
        }];
        button;
    });
    
    [self.resetIconButton addTarget:self action:@selector(_onPressedResetIconImage:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.userNameField addTarget:self action:@selector(_onUserNameChanged:)
               forControlEvents:UIControlEventEditingChanged];
    [self _checkCreateAccountCondition];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.userNameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.userNameField resignFirstResponder];
}

- (void)_checkCreateAccountCondition
{
    [self _setEnable:[self _enableCreateAccount] withButton:self.createUserButton];
}

- (void)_onUserNameChanged:(id)sender
{
    [self _checkCreateAccountCondition];
}

- (BOOL)_enableCreateAccount
{
    if (!self.iconURL) {
        return NO;
    }
    NSString *userName = self.userNameField.text;
    if (![userName isMatchedByRegex:@"(\\w|_|\\d)+"]) {
        return NO;
    }
    if (!(userName.length > 5 && userName.length <= 20)) {
        return NO;
    }
    return YES;
}

- (void)_onPressedResetIconImage:(id)sender
{
    if ([self _checkCameraAuthorizationStatus]) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void)_onPressedCreateAccount:(id)sender
{
    LDUser *user = [LDUser sharedUser];
    [user resetUserName:self.userNameField.text andIconURL:self.iconURL];
    
    [[LDServer sharedServer] postUserName:user.userName withIconURL:user.iconURL withComplete:^{
        
        id<LDLoginFlowViewControllerDelegate> delegate = self.rootFlowViewController.delegate;
        if ([delegate respondsToSelector:@selector(flowViewControllerComplete:)]) {
            [delegate flowViewControllerComplete:self];
        }
    } withFail:^(NSError * _Nullable responseError) {
        
    }];
}

- (BOOL)_checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            return NO;
        }
    }
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)pickedImage editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    pickedImage = [pickedImage fixOrientation];
    
    self.iconImageView.image = ({
        
        CGSize imageSize = CGSizeMake(160, 160);
        UIImage *image = pickedImage;
        
        if (!CGSizeEqualToSize(imageSize, pickedImage.size)) {
            CGImageRef imageRef = pickedImage.CGImage;
            CGRect pickedRect = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
            
            if (pickedRect.size.width > pickedRect.size.height) {
                pickedRect.origin.x = (pickedRect.size.width - pickedRect.size.height)/2;
                pickedRect.size.width = pickedRect.size.height;
                
            } else if (pickedRect.size.width < pickedRect.size.height) {
                pickedRect.origin.y = (pickedRect.size.height - pickedRect.size.width)/2;
                pickedRect.size.height = pickedRect.size.width;
            }
            imageRef = CGImageCreateWithImageInRect(pickedImage.CGImage, pickedRect);
            
            UIGraphicsBeginImageContext(imageSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageRef);
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        image;
    });
    
    [self _uploadImage:self.iconImageView.image];
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

- (void)_uploadImage:(UIImage *)image
{
    [self setIconURL:nil];
    [self _checkCreateAccountCondition];
    
    NSLog(@"token : %@", self.uploadToken);
    
    [self.view makeToast:LDString("start-uploading-icon") duration:1.2 position:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:[QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.zone = [QNZone zone1]; //华北存储区域入口
        }]];
        
        [upManager putFile:[self _imagePath:image] key:nil token:self.uploadToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            if (info.statusCode == 200) {
                NSString *imageKey = resp[@"key"];
                NSString *imageDomain = [LDLivingConfiguration sharedLivingConfiguration].imageDomain;
                NSString *imageURL = [NSString stringWithFormat:@"http://%@/%@", imageDomain, imageKey];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setIconURL:imageURL];
                    [self _checkCreateAccountCondition];
                    [self.view makeToast:LDString("finish-uploading-icon") duration:1.2
                                position:CSToastPositionCenter];
                    
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:LDString("failed-to-upload-icon") duration:1.2
                                position:CSToastPositionCenter];
                });
            }
        } option:nil];
    });
}

- (NSString *)_imagePath:(UIImage *)Image {
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/upload_icon.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}

@end
