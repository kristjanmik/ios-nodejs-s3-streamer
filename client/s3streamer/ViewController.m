//
//  ViewController.m
//  s3streamer
//
//  Created by Kristján Ingi Mikaelsson on 26/04/2015.
//  Copyright (c) 2015 Appollo x. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self upload:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]];
}

-(NSString *) url{
    return @"http://localhost:3200";
}

-(NSString *) apiKey{
    return @"abcdefg";
}

-(void) upload: (NSString *)assetPath{
    
    //Create the request with the final url
    NSMutableURLRequest * request = [NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/upload",[self url]]]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:30.0];
    
    //Do a POST request
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self apiKey] forHTTPHeaderField:@"App-Apikey"];
    
    //Make the entire file as the body of the request via stream
    [request setHTTPBodyStream:[NSInputStream
                                inputStreamWithFileAtPath:assetPath]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
        CGFloat uploadPercentage = (float)totalBytesRead / totalBytesExpectedToRead;
        NSLog(@"PROGRESS %f",uploadPercentage);
    }];
    
    operation.responseSerializer =  [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSLog(@"Success in uploading: %@ %@", operation.responseString,operation.responseObject);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSLog(@"Error in uploading: %@,%@,%ld", error,operation.responseString,(long)operation.response.statusCode);
    }];
    
    [operation start];
    
}
@end
