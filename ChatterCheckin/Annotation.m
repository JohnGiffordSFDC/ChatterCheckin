//
//  AddressAnnotation.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/15/13.
//  Copyright (c) 2013 Model Metrics. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

- (void)dealloc {
    [self setTitle:nil];
    [self setSubtitle:nil];
    
    [super dealloc];
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtitle;
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        [_title release];
        _title = [title retain];
    }
}

- (void)setSubtitle:(NSString *)subtitle {
    if (_subtitle != subtitle) {
        [_subtitle release];
        _subtitle = [subtitle retain];
    }
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c {
    [self setCoordinate:c];
    return self;
}

@end
