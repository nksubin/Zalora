//
//  Home.h
//  Zalora
//
//  Created by Subin Kurian on 9/12/15.
//  Copyright (c) 2015 Subin Kurian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Home : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property(nonatomic,strong)NSMutableArray*result;
@property IBOutlet UISearchBar *SearchBar;
@property (nonatomic,strong)NSString * order;
@property(nonatomic,strong) NSString*searchText;
@property(nonatomic,assign)int otherflags;
@end
