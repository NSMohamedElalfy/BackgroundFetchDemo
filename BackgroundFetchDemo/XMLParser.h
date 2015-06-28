//
//  XMLParser.h
//  BackgroundFetchDemo
//
//  Created by Gabriel Theodoropoulos on 18/2/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject <NSXMLParserDelegate>

-(id)initWithXMLURLString:(NSString *)xmlUrlString;

-(void)startParsingWithCompletionHandler:(void(^)(BOOL success, NSArray *dataArray, NSError *error))completionHandler;

@end
