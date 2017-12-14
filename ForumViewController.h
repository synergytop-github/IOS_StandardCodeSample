//
//  ForumViewController.h
//  VoteworthyIndia
//
//  Created by SynergyTop on 04/10/17.
//  Copyright © 2017 Objectsol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "VZMDetailBottomView.h"
#import "ForumTopicView.h"
#import "PECropViewController.h"
@class VZMDetailBottomView;

@interface ForumViewController : UIViewController{
    NSString *localfilePath;

    float timeZoneOffSet;
    NSString *filename,*newPath;
    NSInteger postid_For_ImagePost;
    NSArray *paths;
    NSMutableArray *rowHeight;

    BOOL isImageExist;
    NSMutableArray *arr_response;
    ForumTopicView *topicListView;
    CLLocationManager *locationManager;
    BOOL LIKEBtnSelected;
    BOOL UNLIKEBtnSelected;
    CGFloat image_height;
}
@property (nonatomic, strong) NSIndexPath *savedIndexPathForThePressedCell;

@property(nonatomic, weak) IBOutlet UITableView *forumTable;
@property(nonatomic, strong) IBOutlet HPGrowingTextView* bottomTextView;
@property(nonatomic, weak) IBOutlet UIButton* postBtn;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet VZMDetailBottomView* bottomBar;
@property(nonatomic,strong)UIImagePickerController *imgPkrController;
@property (strong, nonatomic) UIImage  *selectedImage;

@property(nonatomic, weak) IBOutlet UIButton* addImageBtn;
@property(nonatomic, strong)NSArray *arrayList;
-(void)showInView:(UIView *)inView;

@end
