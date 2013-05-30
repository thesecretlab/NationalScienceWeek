//
//  EventListCell.m
//  NSWApp
//
//  Created by Nicholas Wittison on 20/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventListCell.h"
#import "UACellBackgroundView.h"
#import "PrettyTableViewCell.h"
@implementation EventListCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
    if (self) {
        //self.backgroundView = [[PrettyTableViewCell alloc] initWithFrame:CGRectZero];
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
         //self.backgroundView = [[PrettyTableViewCell alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setPosition:(UACellBackgroundViewPosition)newPosition {
//    [(UACellBackgroundView *)self.backgroundView setPosition:newPosition];
//}




@end
