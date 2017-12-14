//
//  ForumViewController.m
//  VoteworthyIndia
//
//  Created by SynergyTop on 04/10/17.
//  Copyright © 2017 Objectsol. All rights reserved.
//

#import "ForumViewController.h"
#import "ForumTableViewCell.h"
#import "ForumDetailViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "ForumTopicsViewController.h"
#import "ForumTopicView.h"
#import "ForumWithImageTableViewCell.h"
#import "NSDate+NVTimeAgo.h"
#import "PECropViewController.h"


#define Screen_Width [[UIScreen mainScreen] bounds].size.width

@interface ForumViewController () <UIImagePickerControllerDelegate, HPGrowingTextViewDelegate, VZMDetailBottomViewDelgate, UINavigationControllerDelegate, forumDetailDelegate,forumDetailDelegate1, VZMDetailBottomViewDelgate, selectDelegate, CLLocationManagerDelegate, PECropViewControllerDelegate>

@end

@implementation ForumViewController

#pragma mark Override methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bottomBar setType:VZMDetailBottomViewTypeMessageView];
    locationManager = [[CLLocationManager alloc]init];

    [self showCurrentLocation];
    self.forumTable.layer.cornerRadius = 5;
   // self.forumTable.layer.borderWidth = 1;
    //self.forumTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bottomTextView.layer.cornerRadius = 10;

    self.bottomTextView.layer.cornerRadius = 5;
    self.postBtn.layer.cornerRadius = 5;
    self.bottomBar.barDelegate = self;
    self.imgPkrController = [[UIImagePickerController alloc]init];
    self.imgPkrController.delegate = self;

    self.forumTable.estimatedRowHeight = [ForumTableViewCell height];
     self.forumTable.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view from its nib.
    
    
    [self WebServiceForforumData];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // [self.bottomBar.messageView clear];
    
    // [self.forumTable reloadData];
}

#pragma mark location delegate & functions
-(void)showCurrentLocation {
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100.0;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    
    locationManager.allowsBackgroundLocationUpdates = YES;
    if(nil == locationManager) locationManager = [[CLLocationManager alloc]init];
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    //locationManager.distanceFilter=10;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    /* UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Failed to get your location" preferredStyle:UIAlertControllerStyleActionSheet];
     
     UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     [alert dismissViewControllerAnimated:YES completion:nil];
     
     }];
     [alert addAction:ok];
     [self presentViewController:alert animated:YES completion:nil];
     
     */
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    /*   CLLocation *newLocation = [locations lastObject];
     
     CLLocation *oldLocation;
     if (locations.count > 1) {
     oldLocation = [locations objectAtIndex:locations.count-2];
     } else {
     oldLocation = nil;
     }
     CLLocation *location = [locations lastObject];
     
     NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
     
     NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
     //  MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
     //  [regionsMapView setRegion:userLocation animated:YES];}
     
     
     
     
     */
    [locationManager stopUpdatingLocation]; // stop location manager
    locationManager.delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [geocoder reverseGeocodeLocation:locationManager.location
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                           
                           if (error){
                               NSLog(@"Geocode failed with error: %@", error);
                               return;
                               
                           }
                           
                           
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           
                           NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                           NSLog(@"placemark.country %@",placemark.country);
                           NSLog(@"placemark.postalCode %@",placemark.postalCode);
                           NSLog(@"state %@",placemark.administrativeArea);
                           NSLog(@"city %@",placemark.locality);
                           NSLog(@"placemark.subLocality %@",placemark.subLocality);
                           NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                           
                           
                          NSString *location = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                           
                           [[NSUserDefaults standardUserDefaults]setObject:location forKey:@"stateName"];
                           
                           
                       }];
        
        
    });
    
    // });
    
    
    
}


#pragma mark WebServices functions
-(void)WebServiceForLikePost:(UIButton *)sender {
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    // [parameters setValue:@"111222333" forKey:@"electionTrivia_api_key"];
    
    //[parameters setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"user_id"] forKey:@"user_id"];
    NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"post" forKey:@"type"];
    if([sender.currentImage isEqual:[UIImage imageNamed:@"thumb-up-button.png"]])
    {
        [parameters setValue:@"like" forKey:@"ul_type"];
        [parameters setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"status"];
        
        
    }else {
        [parameters setValue:@"like" forKey:@"ul_type"];
        [parameters setValue:[NSString stringWithFormat:@"%d", 0] forKey:@"status"];
        
    }
    
    [parameters setValue:[[self.arrayList objectAtIndex:sender.tag] valueForKey:@"up_id"] forKey:@"post_id"];
    
    
    NSLog(@".........%@",parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //  AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL,HTTP_BASE_URL_LIKE_FORUM] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSLog(@"%@",responseObject);
         //app.isFavUser=YES;
         dispatch_async(dispatch_get_main_queue(), ^{
             [self WebServiceForforumData];
             
         });
         
         
         return ;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
         [SVProgressHUD dismiss];
         //  NSString *strFailure = [error localizedDescription];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"It seems server is not responding or check your internet connection!" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 
                 //do something when click button
             }];
             [alert addAction:okAction];
             
             [self presentViewController:alert animated:YES completion:nil];
             
         });
         
     }];
    
    
}

-(void)WebServiceForUnlikePost:(UIButton *)sender {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    
    
    [parameters setValue:[[self.arrayList objectAtIndex:sender.tag] valueForKey:@"up_id"] forKey:@"post_id"];
    
    [parameters setValue:@"post" forKey:@"type"];
    if([sender.currentImage isEqual:[UIImage imageNamed:@"thumb-down-button.png"]])
    {
        [parameters setValue:@"unlike" forKey:@"ul_type"];
        [parameters setValue:[NSString stringWithFormat:@"%d", 0] forKey:@"status"];
        
    }else {
        [parameters setValue:@"unlike" forKey:@"ul_type"];
        [parameters setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"status"];
        
    }
    
    
    NSLog(@".........%@",parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL,HTTP_BASE_URL_UNLIKE_FORUM] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         // [self.fav setImage:[UIImage imageNamed:@"like11.png"] forState:UIControlStateNormal];
         NSLog(@"%@",responseObject);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self WebServiceForforumData];
             
         });
         // app.isFavUser=NO;
         // return ;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
         [SVProgressHUD dismiss];
         //  NSString *strFailure = [error localizedDescription];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"It seems server is not responding or check your internet connection!" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 
                 //do something when click button
             }];
             [alert addAction:okAction];
             
             [self presentViewController:alert animated:YES completion:nil];
             
         });
         
     }];
    
    
    
}


-(void)callDeleteWebService:(NSDictionary *)info {
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    //[parameters setValue:@"111222333" forKey:@"electionTrivia_api_key"];
    //[parameters setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] forKey:@"user_id"];
    NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[info valueForKey:@"up_id"] forKey:@"post_id"];
    [parameters setValue:@"" forKey:@"comment_id"];
    [parameters setValue:@"post" forKey:@"type"];

    NSLog(@".........%@",parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //   AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL,HTTP_BASE_URL_FORUM_DELETE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSLog(@"%@",responseObject);
         //app.isFavUser=YES;
         dispatch_async(dispatch_get_main_queue(), ^{
             //    [self webServiceForCommentsList];
            // [self.forumTable beginUpdates];

            // [self.forumTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.savedIndexPathForThePressedCell.row inSection:self.savedIndexPathForThePressedCell.section]] withRowAnimation:UITableViewRowAnimationFade];
             
           //  [self.forumTable endUpdates];
             [self WebServiceForforumData];
             
         });
         
         
         return ;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     //NSString *strFailure = [error localizedDescription];
     
     {
         
         NSLog(@"error - %@", error.localizedDescription);
         
         [SVProgressHUD dismiss];
         //  NSString *strFailure = [error localizedDescription];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"It seems server is not responding or check your internet connection!" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 
                 //do something when click button
             }];
             [alert addAction:okAction];
             
             [self presentViewController:alert animated:YES completion:nil];
             
         });
         
     }];
    
    
    

}


-(void)WebServiceForDataPostWithInfo:(NSDictionary *)info {
    
    
    NSArray *intrst = [[NSUserDefaults standardUserDefaults] objectForKey:@"post_id_selected"];
    
    if(!intrst.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Please select a interest!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //do something when click button
        }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    [self.bottomBar.messageView clear];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    
    [parameters setValue:[info valueForKey:@"message"] forKey:@"comment"];
    [parameters setValue:[intrst objectAtIndex:0] forKey:@"interest_id"];
    
    NSLog(@".........%@",parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL,HTTP_BASE_URL_ADD_POST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSIndexPath* ipath = [NSIndexPath indexPathForRow: 0 inSection:0];
        // [self.forumTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
         
         NSLog(@"%@",responseObject);
         postid_For_ImagePost = [[responseObject valueForKey:@"id"] doubleValue];
         
         if([info valueForKey:@"attachments"] ) {
             
             if([info valueForKey:@"message"]) {
                 [self webServiceForImagePostWithID:postid_For_ImagePost];

             }else {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Please enter comment!" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                     
                     //do something when click button
                 }];
                 [alert addAction:okAction];
                 
                 [self presentViewController:alert animated:YES completion:nil];
                 return ;
             }

         }else {
             [self WebServiceForforumData];

         }
        // _textView.text=@"";
        // currentPage = 0;
                // return ;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
         [SVProgressHUD dismiss];
         //  NSString *strFailure = [error localizedDescription];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"It seems server is not responding or check your internet connection!" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 
                 //do something when click button
             }];
             [alert addAction:okAction];
             
             [self presentViewController:alert animated:YES completion:nil];
             
         });
         
     }];
    

}

-(void)webServiceForImagePostWithID:(double)post_id {
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Loading.."];
        
    });
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    // post body
    [self.bottomBar.addedAttachmenView clearAttachmentView];

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    
    
     NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)post_id] forKey:@"post_id"];
    
  //  NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:@"info_POST_Dict"];
    
   // NSArray *intrst = [[NSUserDefaults standardUserDefaults] objectForKey:@"post_id_selected"];

   // [parameters setObject:[intrst objectAtIndex:0] forKey:@"interest_id"];

    [parameters setObject:@"post" forKey:@"action"];

    
    [parameters setObject:@"base64image" forKey:@"type"];
    
    
    //NSMutableData *body = [NSMutableData data];
    NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.3);
    NSData *base64Str = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [parameters setObject:base64Str forKey:@"base64image"];
    
    NSString *strURL = [NSString stringWithFormat:@"%@add_imageUpload", BASE_URL];
    
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [manager POST:strURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        [formData appendPartWithFileData:imageData
                                    name:@"primary_photo"
                                fileName:@"image.jpg" mimeType:@"image/jpeg"];
        
    }  success:^(AFHTTPRequestOperation *operation, id responseObject1) {
        NSLog(@"Response: %@", responseObject1);
        [SVProgressHUD dismiss];
        NSArray *data = [responseObject1 valueForKey:@"image"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self WebServiceForforumData];
            
            // [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"facebook_image_link"] forKey:@"profileImage"];
          //  self.image_profile.image = self.selectedImage;
            
            
            
            
            
            
            
            
            
            // [[NSUserDefaults standardUserDefaults]setValue:[data  valueForKey:@"facebook_image_link"] forKey:@"user_image"];
            
            // [self loadCellImage:image_profile imageUrl:[data valueForKey:@"political_view_image"]];
            
          //  image_profile.layer.cornerRadius=image_profile.frame.size.width/2;
          //  image_profile.clipsToBounds=YES;
          //  image_profile.layer.borderWidth=2;
          //  image_profile.layer.borderColor=[UIColor whiteColor].CGColor;
           
            
         //   [self.main_view addSubview:image_profile];
            
            
            
            
            
            
            
            /*UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Profile picture updated successfully." message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
                [alert dismissViewControllerAnimated:YES completion:nil];
                
            }];
            //        UIAlertAction cancel = [UIAlertAction actionWithTitle:@"Cancel"style:UIAlertActionStyleDefault handler:^(UIAlertAction  action){
            //            [alert dismissViewControllerAnimated:YES completion:nil];}];
            [alert addAction:ok];
            //[alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            */
            
        });
        
        
        
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@",error);
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        [SVProgressHUD dismiss];
    }];
    
    
    
    /////////////////////////////////////////////////////////////////////
    
    /* NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
     
     NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
     
     [_params setObject:token forKey:@"token"];
     [_params setObject:@"base64image" forKey:@"type"];
     //[_params setObject:@"base64image" forKey:@"type"];
     
     // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
     NSString *BoundaryConstant = [NSString stringWithFormat:@"----------V2ymHFg03ehbqgZCaKO6jy"];
     
     // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
     NSString* FileParamConstant = [NSString stringWithFormat:@"base64image"];
     
     // the server url to which the image (or the media) is uploaded. Use your server url here
     //NSString *strUrl = [NSString stringWithFormat:@"%@",BASEURL];
     //NSURL* requestURL = [NSURL URLWithString:strUrl];
     
     // create request
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
     [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
     [request setHTTPShouldHandleCookies:NO];
     [request setTimeoutInterval:60];
     [request setHTTPMethod:@"POST"];
     // set Content-Type in HTTP header
     NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
     [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
     
     // post body
     NSMutableData *body = [NSMutableData data];
     NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.3);
     NSData *base64Str = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
     [_params setObject:base64Str forKey:@"base64image"];
     
     // add params (all params are strings)
     for (NSString *param in _params) {
     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
     }
     
     // Add image data
     
     if (imageData) {
     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant, base64Str] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n; file_data:"] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:imageData];
     [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
     }
     [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
     
     // setting the body of the post to the reqeust
     [request setHTTPBody:body];
     
     // set the content-length
     NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
     [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
     
     NSString *strURL = [NSString stringWithFormat:@"%@imageUpload", BASE_URL];
     
     // Set URL
     [request setURL:[NSURL URLWithString:strURL]];
     
     NSURLSession *session = [NSURLSession sharedSession];
     NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     if (error) {
     NSLog(@"%@", error);
     [SVProgressHUD dismiss];
     } else {
     //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
     // NSLog(@"%@", httpResponse);
     
     [SVProgressHUD dismiss];
     
     NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
     
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     
     if (self.selectedImage != nil)
     {
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
     NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString* path = [documentsDirectory stringByAppendingPathComponent:
     [NSString stringWithFormat: @"userimage.png"] ];
     NSData* data = UIImagePNGRepresentation(self.selectedImage);
     [data writeToFile:path atomically:YES];
     }
     [[NSUserDefaults standardUserDefaults] setObject:[[responseDict valueForKey:@"data"] valueForKey:@"image_name"] forKey:@"profileImage"];
     self.image_profile.image = self.selectedImage;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshImage" object:nil];
     
     UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Profile picture updated successfully." message:@"" preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
     [alert dismissViewControllerAnimated:YES completion:nil];
     
     }];
     //        UIAlertAction cancel = [UIAlertAction actionWithTitle:@"Cancel"style:UIAlertActionStyleDefault handler:^(UIAlertAction  action){
     //            [alert dismissViewControllerAnimated:YES completion:nil];}];
     [alert addAction:ok];
     //[alert addAction:cancel];
     [self presentViewController:alert animated:YES completion:nil];
     
     
     });
     }
     }];
     [dataTask resume];*/
    
    
    
    

}

-(void)WebServiceForforumData {
    
    [SVProgressHUD show];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    //[parameters setValue:@"111222333" forKey:@"electionTrivia_api_key"];
    //[parameters setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] forKey:@"user_id"];
    NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"Login_Token"];
    [parameters setValue:token forKey:@"token"];
    
    NSLog(@".........%@",parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //   AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@",BASE_URL,HTTP_BASE_URL_FORUM] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         arr_response=(NSMutableArray *)responseObject;
         
         NSArray *data = [responseObject objectForKey:@"data"];
         
         self.arrayList = data;
         
         
         if (self.arrayList.count>0) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.forumTable reloadData];
                // NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.arrayList count] inSection:0];
                //  [self.forumTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
               //  [self.self.forumTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.arrayList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

             });
             
         }else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"No Forum available to show." preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                     
                     //do something when click button
                 }];
                 [alert addAction:okAction];
                 
                 [self presentViewController:alert animated:YES completion:nil];
                 
             });
         }
         
         
         
         
         return ;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     
     {
         

         [SVProgressHUD dismiss];
         NSString *strFailure = [error localizedDescription];

         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"It seems server is not responding or check your internet connection!" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 
                 //do something when click button
             }];
             [alert addAction:okAction];
             
             [self presentViewController:alert animated:YES completion:nil];
             
         });
         
     }];
    
    

    
    
}




-(void)resignResponder {
    
    [self.bottomBar.messageView resignFirstResponder];
}


#pragma mark-ImageConverter
- (void)loadCellImage:(UIImageView *)imageView imageUrl:(NSString *)imageURL forCell:indexPath andCELL:(ForumTableViewCell *)cell
{
    if (imageURL)
    {
        imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_URL, imageURL];
        
        
        [[imageView viewWithTag:99] removeFromSuperview];
        
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = imageView;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                     placeholderImage:nil
                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                                     activityIndicator.tag = 99;
                                     activityIndicator.center = weakImageView.center;
                                     [activityIndicator startAnimating];
                                 }
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                               // dispatch_async(dispatch_get_main_queue(), ^{
                                
//                                float newwidth;
//                                float newheight;
//
//
//                                if (image.size.height>=image.size.width){
//                                    newheight=image.size.height;
//                                    newwidth=(image.size.width/image.size.height)*newheight;
//
//                                    if(newwidth>image.size.width){
//                                        float diff=image.size.width-newwidth;
//                                        newheight=newheight+diff/newheight*newheight;
//                                        newwidth=image.size.width;
//                                    }
//
//                                }
//                                else{
//                                    newwidth=image.size.width;
//                                    newheight=(image.size.height/image.size.width)*newwidth;
//
//                                    if(newheight>image.size.height){
//                                        float diff=image.size.height-newheight;
//                                        newwidth=newwidth+diff/newwidth*newwidth;
//                                        newheight=image.size.height;
//                                    }
//                                }
                                
                                
                                CGFloat aspect = image.size.width / image.size.height;
                                
                                
//
//                                if(image.size.width > image.size.height) {
//                                    image_height = (self.view.frame.size.width * image_height / image.size.width);
//                                }
                                
                                
                              /*  UIImage *img = cell.postImageView.image;
                                
                                int image_width1 = img.size.width;
                                int image_height1 = img.size.height;
                                image_width1 = Screen_Width;
                                image_height1 = (Screen_Width * img.size.height / img.size.width);
                                if(image_width1 > image_height1) {
                                    image_height1 = (Screen_Width * image_height / image_width1);
                                }
                               // cell.postImageView.frame = CGRectMake(cell.postImageView.frame.origin.x, cell.postImageView.frame.origin.y,
                                                               // image_width1,image_height);
                                
                                image_height =  image_height1;//CGRectGetMaxY(cell.postImageView.frame);
                               // cell.imageViewHeightConstraint.constant = image_height;
                                cell.postImageView.frame = CGRectMake(cell.postImageView.frame.origin.x, cell.postImageView.frame.origin.y,
                                                                image_width1,image_height);

                                
                                
                                    [[NSUserDefaults standardUserDefaults] setFloat:image_height forKey:@"IMAGE_HEIGHT"];
                                  //  [self.forumTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

                               // });
                               
                                */
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
    }
    
}
- (void)loadCellImage:(UIImageView *)imageView imageUrl:(NSString *)imageURL
{
    if (imageURL)
    {
        imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_URL, imageURL];
        
        
        [[imageView viewWithTag:99] removeFromSuperview];
        
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = imageView;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                     placeholderImage:nil
                              options:SDWebImageProgressiveDownload
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 if (!activityIndicator) {
                                     [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                                     activityIndicator.tag = 99;
                                     activityIndicator.center = weakImageView.center;
                                     [activityIndicator startAnimating];
                                 }
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               
                                
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
    }
    
}

#pragma mark Image upload & edit methods
-(void)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = _selectedImage;
    controller.keepingCropAspectRatio = YES;
    UIImage *image = _selectedImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}



-(void)openImageOptions{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an action" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imgPkrController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imgPkrController animated:YES completion:^{
        }];
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imgPkrController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imgPkrController animated:YES completion:^{
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    [alert addAction:library];
    [alert addAction:camera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            /* if (self.popover.isPopoverVisible) {
             [self.popover dismissPopoverAnimated:NO];
             }
             
             [self updateEditButtonEnabled];
             
             [self openEditor:nil];*/
        } else {
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor:nil];
            }];
    }

   
    
}
}
    
    
    

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   // [self.bottomBar.barDelegate didCancelImagePickingWithPicker:self];
    [picker dismissViewControllerAnimated:YES completion:nil];

}
-(void)didCancelImagePickingWithPicker:(ForumViewController *)_picker
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)didSelectedStaticImage:(UIImage *)selectedImage {

    [self.bottomBar.messageView setHasAttachments:YES];
    [self didSelectedImageForAttachment:selectedImage picker:self];

}

-(void)didSelectedImageForAttachment:(UIImage *)selectedImage picker:(ForumViewController *)_picker {
    [self.bottomBar.addedAttachmenView addImage:selectedImage];
    [self.bottomBar relayoutWithAnimation:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.bottomBar.messageView setHasAttachments:YES];
    
}

- (IBAction)showImagePicker:(id)sender
{
    [self.bottomTextView resignFirstResponder];
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - TableView Delegate & Datasource

- (CGFloat)tableView:(UITableViewCell *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    

    if(!isImageExist) {
        height = [ForumWithImageTableViewCell height];
    }else {
        
        
      //  height = image_height;
        
        //[[NSUserDefaults standardUserDefaults] floatForKey:@"IMAGE_HEIGHT"];

        height = [ForumTableViewCell height];

    }
    return height;
}

- (NSInteger)tableView:(UITableViewCell *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayList.count ;// [self.topicArray count];
    
}
-(void)tableView:(UITableViewCell *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
//    if ([((ForumTableViewCell*)cell) respondsToSelector:@selector(setLayoutMargins:)])
//    {
//        [((ForumTableViewCell*)cell) setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell;
    NSDictionary *dict = [self.arrayList objectAtIndex:indexPath.row];
    
    
   
    NSString *postImageURL = [[dict valueForKey:@"image"] objectAtIndex:0];
    
    if(postImageURL) {
        cell = (ForumTableViewCell *)[self.forumTable dequeueReusableCellWithIdentifier:[ForumTableViewCell cellIdentifier]];
        
        if (cell == nil) {
            cell=[ForumTableViewCell cell];
            
            ((ForumTableViewCell*)cell).indentationLevel = 1;
            ((ForumTableViewCell*)cell).indentationWidth = 150;
        }
        ((ForumTableViewCell*)cell).forumdelegate = self;
        ((ForumTableViewCell*)cell).tag = indexPath.row;
        ((ForumTableViewCell*)cell).contentView1.layer.cornerRadius = 5;
        
        //[((ForumTableViewCell*)cell).postImageView sizeToFit];
      //  [((ForumTableViewCell*)cell).postImageView clipsToBounds];
        
        [self loadCellImage:((ForumTableViewCell*)cell).postImageView imageUrl:[postImageURL valueForKey:@"image_name"] forCell:indexPath andCELL:((ForumTableViewCell*)cell)];
        
       /* UIImage *img = ((ForumTableViewCell*)cell).postImageView.image;
        int image_width1 = img.size.width;
        int image_height1 = img.size.height;
        image_width1 = Screen_Width;
        image_height1 = (Screen_Width * img.size.height / img.size.width);
        if(image_width1 > image_height1) {
            image_height1 = (Screen_Width * image_height1 / image_width1);
        }
        ((ForumTableViewCell*)cell).postImageView.frame = CGRectMake(((ForumTableViewCell*)cell).postImageView.frame.origin.x, ((ForumTableViewCell*)cell).postImageView.frame.origin.y,
                                        image_width1,image_height);
        image_height =  CGRectGetMaxY(((ForumTableViewCell*)cell).postImageView.frame);
       // [((ForumTableViewCell*)cell) layoutIfNeeded];*/
       //  [self.forumTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
       // ((ForumTableViewCell*)cell).imageHeight.constant = 129;
       // ((ForumTableViewCell*)cell).postImageView.hidden = NO;
        
       // ((ForumTableViewCell*)cell).likeLblTop.constant = 144;
      //  ((ForumTableViewCell*)cell).likeBtnTop.constant = 144;
      //  ((ForumTableViewCell*)cell).unlikeBtnTop.constant = 144;
      //  ((ForumTableViewCell*)cell).shareBtnTop.constant = 144;
        
        
        isImageExist = YES;
        // [self.view layoutIfNeeded];
        
        
        
        [((ForumTableViewCell*)cell).likeBtn addTarget:self action:@selector(likeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumTableViewCell*)cell).likeBtn.tag = indexPath.row;
        
        [((ForumTableViewCell*)cell).unlikeBtn addTarget:self action:@selector(unlikeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumTableViewCell*)cell).unlikeBtn.tag = indexPath.row;
        
        [((ForumTableViewCell*)cell).commentBtn addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumTableViewCell*)cell).commentBtn.tag = indexPath.row;
        
        [((ForumTableViewCell*)cell).shareBtn addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumTableViewCell*)cell).shareBtn.tag = indexPath.row;
        
        [((ForumTableViewCell*)cell).moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumTableViewCell*)cell).moreBtn.tag = indexPath.row;
        
        if([[dict valueForKey:@"up_fk_u_id"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"LoggedIn_user_id"]]) {
            
            ((ForumTableViewCell*)cell).moreBtn.hidden = NO;
        }else {
            ((ForumTableViewCell*)cell).moreBtn.hidden = YES;

        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
           /* if(LIKEBtnSelected) {
                [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up-button.png"] forState:UIControlStateNormal];

            }else {
                [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                

            }
            
            if(UNLIKEBtnSelected) {
                [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down-button.png"] forState:UIControlStateNormal];
                
            }else {
                [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
                
                
            }*/
           // thumb-up.png"

            if (![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"like"]) {
                [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up-button.png"] forState:UIControlStateNormal];
                 [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
                
            }else if(![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"unlike"]) {
                 [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down-button.png"] forState:UIControlStateNormal];
                [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
            }
            else if(![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"other"]){
                 [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                 [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]]){
                [((ForumTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                [((ForumTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
            }

            
            
            

            
            
            ((ForumTableViewCell*)cell).username.text = [dict valueForKey:@"username"];
            ((ForumTableViewCell*)cell).forumName.text = [dict valueForKey:@"interest_name"];
            ((ForumTableViewCell*)cell).userlocation.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"stateName"];
            
            NSInteger score = [[dict valueForKey:@"up_id"] doubleValue];
            
            ((ForumTableViewCell*)cell).forum_id = [NSString stringWithFormat:@"%ld", (long)score];
            
            
            NSString *str= [dict valueForKey:@"facebook_image_link"];
            
            [self loadCellImage:((ForumTableViewCell*)cell).profileImg imageUrl:str];
            
            ((ForumTableViewCell*)cell).likelbl.text = [dict valueForKey:@"user_like"];
            ((ForumTableViewCell*)cell).commentLbl.text = [dict valueForKey:@"user_comment"];
            
            NSString *likecount = [dict valueForKey:@"user_like"];
            NSString *likethis;
            if([[dict valueForKey:@"user_like"] intValue] > 1) {
                likethis = @" likes this!";

            }else {
                likethis = @" like this!";

            }
            
            ((ForumTableViewCell*)cell).likeLabel.text = [likecount stringByAppendingString:likethis];
            
            
            ((ForumTableViewCell*)cell).commenttextView.text = [dict valueForKey:@"up_text"];
            
            NSString *strr=[dict valueForKey:@"up_created"];
            
            NSString *timeAgoFormattedDate = [NSDate mysqlDatetimeFormattedAsTimeAgo:strr];
            
            ((ForumTableViewCell*)cell).datelabel.text=timeAgoFormattedDate;
          
            
            
        });

    }else {
        cell = (ForumWithImageTableViewCell *)[self.forumTable dequeueReusableCellWithIdentifier:[ForumWithImageTableViewCell cellIdentifier]];
        
        if (cell == nil) {
            cell=[ForumWithImageTableViewCell cell];
            
            ((ForumWithImageTableViewCell*)cell).indentationLevel = 1;
            ((ForumWithImageTableViewCell*)cell).indentationWidth = 150;
        }
        ((ForumWithImageTableViewCell*)cell).forumdelegate1 = self;
        ((ForumWithImageTableViewCell*)cell).tag = indexPath.row;
        ((ForumWithImageTableViewCell*)cell).contentView1.layer.cornerRadius = 5;

        
        
        
        if (![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"like"]) {
            [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up-button.png"] forState:UIControlStateNormal];
            [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
            
        }else if(![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"unlike"]) {
            [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down-button.png"] forState:UIControlStateNormal];
            [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
        }
        else if(![[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]] && [[dict valueForKey:@"user_like_unlike"] isEqualToString:@"other"]){
            [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
            [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
        }else if([[dict valueForKey:@"user_like_unlike"]isKindOfClass:[NSNull class]]){
            [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
            [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
        }


        
        
        
        [((ForumWithImageTableViewCell*)cell).likeBtn addTarget:self action:@selector(likeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumWithImageTableViewCell*)cell).likeBtn.tag = indexPath.row;
        
        [((ForumWithImageTableViewCell*)cell).unlikeBtn addTarget:self action:@selector(unlikeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumWithImageTableViewCell*)cell).unlikeBtn.tag = indexPath.row;
        
        [((ForumWithImageTableViewCell*)cell).commentBtn addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumWithImageTableViewCell*)cell).commentBtn.tag = indexPath.row;
        
        [((ForumWithImageTableViewCell*)cell).shareBtn addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumWithImageTableViewCell*)cell).shareBtn.tag = indexPath.row;
        
        
        [((ForumWithImageTableViewCell*)cell).moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        ((ForumWithImageTableViewCell*)cell).moreBtn.tag = indexPath.row;
        

        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
         /*   if(LIKEBtnSelected) {
                [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up-button.png"] forState:UIControlStateNormal];
                
            }else {
                [((ForumWithImageTableViewCell*)cell).likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                
                
            }
            
            if(UNLIKEBtnSelected) {
                [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down-button.png"] forState:UIControlStateNormal];
                
            }else {
                [((ForumWithImageTableViewCell*)cell).unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
                
                
            }*/
            

            
            ((ForumWithImageTableViewCell*)cell).username.text = [dict valueForKey:@"username"];
            ((ForumWithImageTableViewCell*)cell).forumName.text = [dict valueForKey:@"interest_name"];
            ((ForumTableViewCell*)cell).userlocation.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"stateName"];
            
            NSInteger score = [[dict valueForKey:@"up_id"] doubleValue];
            
            ((ForumWithImageTableViewCell*)cell).forum_id = [NSString stringWithFormat:@"%ld", (long)score];
            
            
            NSString *str= [dict valueForKey:@"facebook_image_link"];
            
            [self loadCellImage:((ForumWithImageTableViewCell*)cell).profileImg imageUrl:str];
            
            ((ForumWithImageTableViewCell*)cell).likelbl.text = [dict valueForKey:@"user_like"];
            ((ForumWithImageTableViewCell*)cell).commentLbl.text = [dict valueForKey:@"user_comment"];
            
            NSString *likecount = [dict valueForKey:@"user_like"];
            NSString *likethis;
            if([[dict valueForKey:@"user_like"] intValue] > 1) {
                likethis = @" likes this!";
                
            }else {
                likethis = @" like this!";
                
            }
            
            ((ForumWithImageTableViewCell*)cell).likeLabel.text = [likecount stringByAppendingString:likethis];
            
            
            ((ForumWithImageTableViewCell*)cell).commenttextView.text = [dict valueForKey:@"up_text"];
            
            NSString *strr=[dict valueForKey:@"up_created"];
            NSString *timeAgoFormattedDate = [NSDate mysqlDatetimeFormattedAsTimeAgo:strr];
            
            ((ForumWithImageTableViewCell*)cell).datelabel.text=timeAgoFormattedDate;
            
            
          
        });

        
        

        isImageExist = NO;
        
        
    }
    


    
    
    
    
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /* NSDictionary *dict = [self.topicArray objectAtIndex:indexPath.row];
     
     [[NSUserDefaults standardUserDefaults] setValue:[dict valueForKey:@"up_id"] forKey:@"post_id"];
     
     NSString*interest=[dict valueForKey:@"user_created_interest_name"];
     
     [[NSUserDefaults standardUserDefaults]setValue:interest forKey:@"user_created_interest_name"];
     [[NSUserDefaults standardUserDefaults]setValue:[dict valueForKey:@"political_view_image"] forKey:@"user_political_party_image"];
     
     CommentTopicViewController *ct=[[CommentTopicViewController alloc]initWithNibName:@"CommentTopicViewController" bundle:nil];
     
     [self.navigationController pushViewController:ct animated:YES];*/
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    //handle user taps text view to type text
    //[self adjustFrames];
    
    
}

#pragma mark - Custom cell button action
-(void)unlikeBtnAction:(UIButton *)sender {
    if([sender.currentImage isEqual:[UIImage imageNamed:@"thumb-down-button.png"]])
    {
        [sender  setImage:[UIImage imageNamed: @"thumb-down1.png"] forState:UIControlStateNormal];
        UNLIKEBtnSelected = NO;
        NSUserDefaults *buttonDefault = [NSUserDefaults standardUserDefaults];
        [buttonDefault setBool:YES forKey:@"CHECKMARKEDKEY"];
    }else {
        [sender setImage:[UIImage imageNamed:@"thumb-down-button.png"]forState:UIControlStateNormal];
         UNLIKEBtnSelected = YES;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        id buttonCell = [[[sender superview] superview]superview];
        if([buttonCell isKindOfClass:[ForumTableViewCell class]]) {
            ForumTableViewCell *buttonCell = (ForumTableViewCell *)[[[sender superview] superview]superview];
            // UITableView* table = (UITableView *)[buttonCell superview];
            // NSIndexPath* pathOfTheCell = [table indexPathForCell:buttonCell];
            // NSInteger rowOfTheCell = [pathOfTheCell row];
            
            NSInteger count = [buttonCell.likeLabel.text integerValue];
            
            if(count > 0) {
                
                
                if([buttonCell.likeBtn.currentImage isEqual:[UIImage imageNamed:@"thumb-up-button.png"]])
                {
                    [buttonCell.likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                    if(count>0) {
                        count--;
                        
                    }
                    buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                    
                    NSString *likethis = @" like this!";
                    
                    buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
                    LIKEBtnSelected = NO;
                    
                }
                
                
            }
            
            
        }else {
            ForumWithImageTableViewCell *buttonCell = (ForumWithImageTableViewCell *)[[[sender superview] superview]superview];
            // UITableView* table = (UITableView *)[buttonCell superview];
            // NSIndexPath* pathOfTheCell = [table indexPathForCell:buttonCell];
            // NSInteger rowOfTheCell = [pathOfTheCell row];
            
            NSInteger count = [buttonCell.likeLabel.text integerValue];
            
            if(count > 0) {
                
                
                if([buttonCell.likeBtn.currentImage isEqual:[UIImage imageNamed:@"thumb-up-button.png"]])
                {
                    [buttonCell.likeBtn setImage:[UIImage imageNamed:@"thumb-up.png"] forState:UIControlStateNormal];
                    if(count>0) {
                        count--;
                        
                    }
                    buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                    
                    NSString *likethis = @" like this!";
                    
                    buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
                    LIKEBtnSelected = NO;
                    
                }
                
                
            }
            
            
        }
        // UIButton *senderButton = (UIButton *)sender;
        
    });
    
    [self WebServiceForUnlikePost:sender];
}
-(void)moreBtnAction:(UIButton *)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Delete your post" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    ForumTableViewCell *buttonCell = (ForumTableViewCell *)[[[sender superview] superview]superview];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSDictionary *dict = [self.arrayList objectAtIndex:sender.tag];
        
        if([[dict valueForKey:@"up_fk_u_id"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"LoggedIn_user_id"]]) {
            self.savedIndexPathForThePressedCell = [self.forumTable indexPathForCell:buttonCell];

            [self callDeleteWebService:dict];
        }
        NSLog(@"post deleted");
        // Distructive button tapped.
        [self dismissViewControllerAnimated:YES completion:^{
            
           
        }];
    }]];
    
   
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)likeBtnAction:(UIButton *)sender {
    
    
 //   [sender setImage:[UIImage imageNamed:@"Hearts-48.png"] forState:UIControlStateNormal];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // UIButton *senderButton = (UIButton *)sender;
        id buttonCell = [[[sender superview] superview]superview];
        if([buttonCell isKindOfClass:[ForumTableViewCell class]]) {
            ForumTableViewCell *buttonCell = (ForumTableViewCell *)[[[sender superview] superview]superview];
            NSInteger count = [buttonCell.likeLabel.text integerValue];//[[[self.arrayList valueForKey:@"user_like"] objectAtIndex:sender.tag] integerValue];//[buttonCell.likeLabel.text integerValue];
            
            if([sender.currentImage isEqual:[UIImage imageNamed:@"thumb-up-button.png"]])
            {
                [sender  setImage:[UIImage imageNamed: @"thumb-up.png"] forState:UIControlStateNormal];
                NSUserDefaults *buttonDefault = [NSUserDefaults standardUserDefaults];
                [buttonDefault setBool:YES forKey:@"CHECKMARKEDKEY"];
                LIKEBtnSelected = NO;
                if(count>0) {
                    count--;
                    
                }
                buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                NSString *likethis = @" like this!";
                
                buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
            }else {
                [sender setImage:[UIImage imageNamed:@"thumb-up-button.png"]forState:UIControlStateNormal];
                LIKEBtnSelected = YES;
                
                count++;
                buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                NSString *likethis = @" like this!";
                
                buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
            }
            
            
            //  if(count > 0) {
            [buttonCell.unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
            
            
            //}
            

        }else {
           ForumWithImageTableViewCell * buttonCell = (ForumWithImageTableViewCell *)[[[sender superview] superview]superview];
            NSInteger count = [buttonCell.likeLabel.text integerValue];//[[[self.arrayList valueForKey:@"user_like"] objectAtIndex:sender.tag] integerValue];//[buttonCell.likeLabel.text integerValue];
            
            if([sender.currentImage isEqual:[UIImage imageNamed:@"thumb-up-button.png"]])
            {
                [sender  setImage:[UIImage imageNamed: @"thumb-up.png"] forState:UIControlStateNormal];
                NSUserDefaults *buttonDefault = [NSUserDefaults standardUserDefaults];
                [buttonDefault setBool:YES forKey:@"CHECKMARKEDKEY"];
                LIKEBtnSelected = NO;
                if(count>0) {
                    count--;
                    
                }
                buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                NSString *likethis = @" like this!";
                
                buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
            }else {
                [sender setImage:[UIImage imageNamed:@"thumb-up-button.png"]forState:UIControlStateNormal];
                LIKEBtnSelected = YES;
                
                count++;
                buttonCell.likelbl.text = [NSString stringWithFormat:@"%ld", (long)count];
                NSString *likethis = @" like this!";
                
                buttonCell.likeLabel.text = [[NSString stringWithFormat:@"%ld", (long)count] stringByAppendingString:likethis];
            }
            
            
            //  if(count > 0) {
            [buttonCell.unlikeBtn setImage:[UIImage imageNamed:@"thumb-down1.png"] forState:UIControlStateNormal];
            
            
            //}
            

        }
        
        //  UITableView* table = (UITableView *)[buttonCell superview];
        // NSIndexPath* pathOfTheCell = [table indexPathForCell:buttonCell];
        // NSInteger rowOfTheCell = [pathOfTheCell row];
        
           });
    [self WebServiceForLikePost:sender];
}



-(void)commentBtnAction:(UIButton *)sender {
    
    ForumDetailViewController *mp=[[ForumDetailViewController alloc]initWithNibName:@"ForumDetailViewController" bundle:nil];
    [self.navigationController pushViewController:mp animated:YES];
    

}
// Returns the file path for requested folder name
- (NSURL *)customApplicationDocumentsDirectory:(NSString *)folderNameornil
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (folderNameornil == nil)
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    else
        ///documentsDirectory = [documentsDirectory stringByAppendingPathComponent:folderNameornil];
        
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        // [[VZMKeyChainManager sharedManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:@{NSFileProtectionKey:NSFileProtectionComplete} error:&error];
    }
    NSURL *documentsDirectoryUrl = [NSURL fileURLWithPath:documentsDirectory];
    return documentsDirectoryUrl;
}

#pragma mark - share button logic
-(void)shareBtnAction:(UIButton *)sender {
    
    
    ForumTableViewCell *buttonCell = (ForumTableViewCell *)[[[sender superview] superview]superview];

 //   [self takescreenshotes:sender];
    NSString *textToShare = [[self.arrayList objectAtIndex:sender.tag] valueForKey:@"up_text"];// @"Check out the Voteworthy app. It's awesome!";
        NSURL *url=[NSURL URLWithString:@"https://fb.me/1909849692575335"];
    UIImage*img= buttonCell.postImageView.image; //[UIImage imageWithContentsOfFile:newPath];
    
    NSURL  *img_url = [NSURL URLWithString:[[[[self.arrayList objectAtIndex:sender.tag] valueForKey:@"image"] objectAtIndex:0] valueForKey:@"image_name"]];
    
    NSString * imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_URL, img_url];
    
    NSURL *urlOfImage = [NSURL URLWithString:imageURL];

    
    NSData *urlData = [NSData dataWithContentsOfURL:urlOfImage];
    if ( urlData )
    {
        NSArray       *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths1 objectAtIndex:0];
        
        localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"image.jpeg"];
        [urlData writeToFile:localfilePath atomically:YES];
    }

    
    
    NSArray *objectsToShare;
    if(img_url) {
        objectsToShare = @[textToShare,urlData,url];

    }else {
        objectsToShare = @[textToShare,url];

    }
    
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo, UIActivityTypePostToFacebook];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
    
}
-(void)takescreenshotes:(UIButton *)sender{
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:@"pkm.jpg"];
    
    
    NSString *postImageURL = [[[self.arrayList objectAtIndex:sender.tag] valueForKey:@"image"] objectAtIndex:0];
    
    
    
    
    NSString *imageURL = [postImageURL valueForKey:@"image_name"];
    imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_URL, imageURL];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    [data writeToFile:localFilePath atomically:YES];
    
    
    
    
    
    
    
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data1 = UIImagePNGRepresentation(image);
    
    filename=@"latest.png"; //create a custome file name for your screen shots
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [data1 writeToFile:newPath atomically:YES]; //Path to store the screen shots
    
    UIImage *img = [UIImage imageWithContentsOfFile:newPath];
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data1], nil, nil, nil);
}


#pragma mark - other custom methods
- (void)didSendPostWithInfo:(NSDictionary *)info {
    [self.bottomBar.messageView resignFirstResponder];

    NSArray *intrst = [[NSUserDefaults standardUserDefaults] objectForKey:@"post_id_selected"];

    if(intrst.count>0) {
        
    }
    //before post show intereset list ....
    
    if([info valueForKey:@"message"]) {
        topicListView = [[ForumTopicView alloc] initAlertwithFrame:CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height)];
        topicListView.hideDelegate = self;
        topicListView.layer.cornerRadius = 10;
        
        
        // [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        topicListView.userInteractionEnabled = true;
        self.forumTable.userInteractionEnabled = false;
        
        
        [topicListView showInView:self.view];
        
        /* popup_existing.callBack = ^(NSString * str_Status){
         [SVProgressHUD dismiss];
         [self web_response_for_topic];
         };*/
        
        [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"info_POST_Dict"];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Please enter comment!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //do something when click button
        }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
   
    
    //send data dictionary to server ...
    
    

}

-(void)hideTopicView {
    
    
    self.forumTable.userInteractionEnabled = true;
   // [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    
    [self WebServiceForDataPostWithInfo:[[NSUserDefaults standardUserDefaults] objectForKey:@"info_POST_Dict"]];

    //select button action..
    [topicListView removeFromSuperview];
}
-(void)closeBtn {
    
    
    self.forumTable.userInteractionEnabled = true;
    // [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    
    //[self WebServiceForDataPostWithInfo:[[NSUserDefaults standardUserDefaults] objectForKey:@"info_POST_Dict"]];
    
    //select button action..
    [topicListView removeFromSuperview];
}


-(void)forumDetailLoad:(ForumTableViewCell *)sender {
    [self.bottomBar.messageView resignFirstResponder];

    NSDictionary *dict = [self.arrayList objectAtIndex:sender.tag];
 //   NSInteger score = [[dict valueForKey:@"up_id"] doubleValue];

    [[NSUserDefaults standardUserDefaults] setInteger:sender.tag forKey:@"ForumRowSelected"];
    
      ForumDetailViewController *mp=[[ForumDetailViewController alloc]initWithNibName:@"ForumDetailViewController" bundle:nil];
    mp.arrayList = self.arrayList;
     [self.navigationController pushViewController:mp animated:YES];

}

-(void)forumDetailLoad1:(ForumWithImageTableViewCell *)sender {
    
    NSDictionary *dict = [self.arrayList objectAtIndex:sender.tag];
    //   NSInteger score = [[dict valueForKey:@"up_id"] doubleValue];
    
    [[NSUserDefaults standardUserDefaults] setInteger:sender.tag forKey:@"ForumRowSelected"];
    
    ForumDetailViewController *mp=[[ForumDetailViewController alloc]initWithNibName:@"ForumDetailViewController" bundle:nil];
    mp.arrayList = self.arrayList;
    [self.navigationController pushViewController:mp animated:YES];
    
}

#pragma mark - PECropViewControllerDelegate methods

-(void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    
    
    
}
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    _selectedImage = croppedImage;
    [self didSelectedStaticImage:_selectedImage];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       // [self updateEditButtonEnabled];
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //[self updateEditButtonEnabled];
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark-UITextfield delegate function
-(BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *send_message=_textView.text;
    if ( [ text isEqualToString: @"\n"] ) {
        
        [ _textView resignFirstResponder ];
        return NO;
    }
    if ([send_message length]>0) {
        // btn_send.hidden=NO;
    }
    else{
        //btn_send.hidden=YES;
    }
    
   // [self adjustFrames];
    return YES;
}


-(void) adjustFrames
{
   /* UIImageView *imageView = [[UIImageView alloc] initWithImage:yourImage];
    [imageView setFrame:yourFrame];
    [yourTextView addSubview:imageView];
    
    CGRect aRect = CGRectMake(156, 8, 16, 16);
    [imageView setFrame:aRect];
    UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame), CGRectGetWidth(yourTextView.frame), CGRectGetHeight(imageView.frame))];
    self.bottomTextView.textContainer.exclusionPaths = @[exclusionPath];
    [self.bottomTextView addSubview:imageView];
    */
    
    
    
    
    
  /*  CGRect textFrame = _textView.frame;
    textFrame.size.height = _textView.contentSize.height;
    _textView.frame = textFrame;
    CGFloat height=textFrame.size.height;
    if (IS_IPHONE_6_PLUS) {
        _bottom_view.frame=CGRectMake(0,618-height,414,64+height);
        //self.btn_send.frame=CGRectMake(351, 10, 62, 42);
        //       self.btn_user.frame=CGRectMake(0, 10, 50, 42);
        //        self.textView.frame=CGRectMake(60, 15, 295, height);
    }
    if (IS_IPHONE_6) {
        // self.bottom_view.frame=CGRectMake(-20,550-height,415,54+height);
        // self.bottom_view.frame=CGRectMake(self.bottom_view.bounds.origin.x, self.bottom_view.bounds.origin.y-height, self.bottom_view.frame.size.width, self.bottom_view.frame.size.height+height);
        //self.btn_send.frame=CGRectMake(320, 10, 42, 42);
        //  self.btn_user.frame=CGRectMake(5, 10, 42, 42);
        //  self.textView.frame=CGRectMake(60, 10, 262, height);
        
        // self.bottom_view.frame=CGRectMake(0,630-height,375,58+height);
        
        //self.textView.frame=CGRectMake(55, 10, 262, height);
    }
    if (IS_IPHONE_5) {
        self.bottom_view.frame=CGRectMake(-17,471-height,354,55+height);
        //       self.btn_send.frame=CGRectMake(286, 10, 34, 39);
        //        self.btn_user.frame=CGRectMake(0, 7, 31, 42);
    }
    [self.scroll addSubview:self.bottom_view];
    [self.bottom_view addSubview:btn_send];
    // [self.bottom_view addSubview:self.user_image];
    [self.bottom_view addSubview:self.btn_send];
    [self.bottom_view addSubview:self.textView];
    */
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
