//
//  XMLParser.m
//  BackgroundFetchDemo
//
//  Created by Gabriel Theodoropoulos on 18/2/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParser()

@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) NSMutableArray *arrParsedData;

@property (nonatomic, strong) NSString *currentElement;

@property (nonatomic, strong) NSString *newsTitle;

@property (nonatomic, strong) NSString *newsPubDate;

@property (nonatomic, strong) NSString *newsLink;

@property (nonatomic, strong) void (^completionHandler)(BOOL, NSArray *, NSError *);

@property (nonatomic) BOOL isNewsItem;

@property (nonatomic) BOOL allowedData;


-(void)parse;
-(void)endParsingWithError:(NSError *)error;

@end


@implementation XMLParser

-(id)initWithXMLURLString:(NSString *)xmlUrlString{
    self = [super init];
    if (self) {
        self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:xmlUrlString]];

        self.xmlParser.delegate = self;
        
        self.operationQueue = [NSOperationQueue new];
        
        self.currentElement = @"";
        
        self.isNewsItem = NO;
        
        self.allowedData = NO;
    }
    
    return self;
}


#pragma mark - Public method implementation

-(void)startParsingWithCompletionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler{
    self.completionHandler = completionHandler;
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(parse)
                                                                              object:nil];
    [self.operationQueue addOperation:operation];
}


#pragma mark - Private method implementation

-(void)parse{
    if (self.xmlParser != nil) {
        [self.xmlParser parse];
    }
}

-(void)endParsingWithError:(NSError *)error{
    BOOL success = (error == nil) ? YES : NO;
    
    self.completionHandler(success, self.arrParsedData, error);
}



#pragma mark - NSXMLParserDelegate method implementation

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    if (self.arrParsedData != nil) {
        [self.arrParsedData removeAllObjects];
        self.arrParsedData = nil;
    }
    
    self.arrParsedData = [[NSMutableArray alloc] init];
}


-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self performSelectorOnMainThread:@selector(endParsingWithError:) withObject:nil waitUntilDone:NO];
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"item"]) {
        self.isNewsItem = YES;
    }
    
    if (self.isNewsItem) {
        if ([elementName isEqualToString:@"title"] ||
            [elementName isEqualToString:@"pubDate"] ||
            [elementName isEqualToString:@"link"]) {

            self.allowedData = YES;
        }
    }
    
    self.currentElement = elementName;
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"]) {
        self.isNewsItem = NO;
        
        
        NSDictionary *dict = @{@"title":    self.newsTitle,
                               @"pubDate":  self.newsPubDate,
                               @"link":     self.newsLink
                               };

        [self.arrParsedData addObject:dict];
    }
    
    if (self.isNewsItem) {
        if ([elementName isEqualToString:@"title"] ||
            [elementName isEqualToString:@"pubDate"] ||
            [elementName isEqualToString:@"link"]) {
            
            self.allowedData = NO;
        }
    }
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (self.allowedData) {
        if ([self.currentElement isEqualToString:@"title"]) {
            self.newsTitle = string;
        }
        else if ([self.currentElement isEqualToString:@"pubDate"]){
            self.newsPubDate = string;
        }
        else if ([self.currentElement isEqualToString:@"link"]){
            self.newsLink = string;
        }
    }
}


-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    [self performSelectorOnMainThread:@selector(endParsingWithError:) withObject:parseError waitUntilDone:NO];
}


-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    [self performSelectorOnMainThread:@selector(endParsingWithError:) withObject:validationError waitUntilDone:NO];
}

@end
