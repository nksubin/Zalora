//
//  Home.m
//  Zalora
//
//  Created by Subin Kurian on 9/12/15.
//  Copyright (c) 2015 Subin Kurian. All rights reserved.
//

#import "Home.h"
#import "AsyncImageView.h"
#import "DWBubbleMenuButton.h"
@interface Home ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation Home

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 
    self.result=[NSMutableArray new];
    NSDictionary *receivingData=[[UIAppDelegate download]SendToServerGet:SERVERURL :self.view isBackgroundTask:NO];
    if(TEST==1)NSLog(@"%@",receivingData);
    
    self.result=[receivingData valueForKeyPath:@"metadata.results"];
    
    [self.tableView reloadData];
    [self performSelector:@selector(setup) withObject:nil afterDelay:.5];
}

-(void)setup
{
    self.order=@"asc";
    self.otherflags=2;
    UIImageView *filterImage = [self createHomeButtonView];
    DWBubbleMenuButton *downMenuButton = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - filterImage.frame.size.width,
                                                                                          self.view.frame.size.height - filterImage.frame.size.height,
                                                                                          filterImage.frame.size.width,
                                                                                          filterImage.frame.size.height)
                                                            expansionDirection:DirectionUp];
    downMenuButton.homeButtonView = filterImage;
    
    [downMenuButton addButtons:[self createDemoButtonArray]];
    
    [self.view addSubview:downMenuButton];
    

    
}
- (UIImageView *)createHomeButtonView {
    
    UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
    img.image=[UIImage imageNamed:@"filter"];
    return img;
}

- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (NSString *title in @[@"👍", @"💰"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.showsTouchWhenHighlighted=TRUE;
        button.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor purpleColor];
        button.clipsToBounds = YES;
        button.tag = i++;
        
        [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonsMutable addObject:button];
    }
    
    return [buttonsMutable copy];
}

- (void)test:(UIButton *)sender {

    self.otherflags= (int)sender.tag;
       [self performSelectorInBackground:@selector(filterAction) withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.result.count;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier] ;
    }
    NSDictionary *dataDict =[self.result objectAtIndex:indexPath.row];
    
    NSDictionary *data=[dataDict objectForKey:@"data"];
    UILabel *brand=(UILabel*)[cell viewWithTag:4];
    brand.text=[data objectForKey:@"brand"];
    
    UILabel *name=(UILabel*)[cell viewWithTag:5];
    name.text=[data objectForKey:@"name"];
    
    UILabel *price=(UILabel*)[cell viewWithTag:6];
    price.text=[NSString stringWithFormat:@"$ %@", [data objectForKey:@"price"]];
    
    NSArray *images= [dataDict objectForKey:@"images"];
    NSDictionary *imageinfo1=  ( [images count]>1) ? ( [images objectAtIndex:0]) : (nil);
     NSDictionary *imageinfo2= ( [images count]>=2) ? ( [images objectAtIndex:1]) : (nil);
   
     NSDictionary *imageinfo3=  ([images count]>=3) ? ( [images objectAtIndex:2]) : (nil);

    
    //get image view
    AsyncImageView *imageView1 = (AsyncImageView *)[cell viewWithTag:1];
    
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView1];
    
    //load the image
    imageView1.imageURL =[NSURL URLWithString:[imageinfo1 objectForKey:@"path"]]  ;
    //get image view
    AsyncImageView *imageView2 = (AsyncImageView *)[cell viewWithTag:2];
    
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView2];
    
    //load the image
    imageView2.imageURL =[NSURL URLWithString:[imageinfo2 objectForKey:@"path"]]  ;
    //get image view
    AsyncImageView *imageView3 = (AsyncImageView *)[cell viewWithTag:3];
    
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView3];
    
    //load the image
    imageView3.imageURL =[NSURL URLWithString:[imageinfo3 objectForKey:@"path"]]  ;

    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
  
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
   
    searchBar.text=@"";
    self.searchText=@"";
  [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
     self.searchText=searchBar.text;
        [self performSelectorInBackground:@selector(filterAction) withObject:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
- (IBAction)orderAction:(UIButton *)sender {
    
  if(  [sender.titleLabel.text isEqualToString:@"🔻"])
  {
      [sender setTitle:@"🔺" forState:UIControlStateNormal];
      self.order=@"desc";
  }
    else
    {
        
         [sender setTitle:@"🔻" forState:UIControlStateNormal];
        self.order=@"asc";
    }
    
    [self performSelectorInBackground:@selector(filterAction) withObject:nil];
    
}


-(void)filterAction
{
    NSString *postdata=[NSString stringWithFormat:@"?dir=%@",self.order];
    
//Example: https://www.zalora.com.my/mobile-api/women/clothing?maxItems=24&page=1&sort=price&dir=desc
    
    if(self.searchText.length!=0)
        postdata=[NSString stringWithFormat:@"%@&name%@",self.searchText,postdata];
    if(self.otherflags==0)
        postdata=[NSString stringWithFormat:@"%@&sort=popularity",postdata];
    if(self.otherflags==1)
        postdata=[NSString stringWithFormat:@"%@&sort=price",postdata];
    
    postdata=[NSString stringWithFormat:@"%@%@",SERVERURL,postdata];
    NSDictionary *receivingData=[[UIAppDelegate download]SendToServerGet:postdata :self.view isBackgroundTask:NO];


    
    [self.result removeAllObjects];
    
    self.result=[receivingData valueForKeyPath:@"metadata.results"];
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here

    [self.tableView reloadData];
            });
  
}

@end
