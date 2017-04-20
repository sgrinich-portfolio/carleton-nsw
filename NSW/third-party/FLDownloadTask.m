//
//  FLDownloadTask.m
//  FileSafe
//
//  Created by Lombardo on 17/11/13.
//
//

#import "FLDownloadTask.h"

@interface FLDownloader (Private)

-(void)saveDownloads;

@end

/**
 Constants for NSCoding
 */
static NSString *kFLDownloadEncodedURL = @"kFLDownloadEncodedURL";
static NSString *kFLDownloadEncodedDestinationDirectory = @"kFLDownloadEncodedDestinationDirectory";
static NSString *kFLDownloadEncodedType = @"kFLDownloadEncodedType";


@interface FLDownloadTask ()

/**
 This is the underlying download task associated with the object
 */
@property (weak, nonatomic, readwrite) id downloadTask;

/**
 The download url
 */
@property (strong, nonatomic, readwrite) NSURL *url;

@end

@implementation FLDownloadTask

#pragma mark - init

// this is a private init method (hidden). The real init method raise an exception. Like a real init method
// here we call [super init]
- (id)initPrivate
{
    if (self = [super init]) {
        _downloadTask = nil;
        _url = nil;
        _destinationDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) lastObject];
        _type = FLDownloadTaskTypeDownload;
    }
    return self;
}

// raise an exception
- (id)init {
    
    [NSException exceptionWithName:@"InvalidOperation" reason:@"Cannot invoke init on a FLDownloadTask. Use [FLDownloader/FLDownloadTask downloadTaskForURL] to create a new instance." userInfo:nil];
    return nil;
}

+(FLDownloadTask *)downloadTaskForURL:(NSURL *)url
{
    FLDownloadTask *task = [[FLDownloader sharedDownloader] downloadTaskForURL:url];
    return task;
}

+(FLDownloadTask *)uploadTaskForURL:(NSURL *)url fromFile:(NSURL *)filePath
{
    FLDownloadTask *task = [[FLDownloader sharedDownloader] uploadTaskForURL:url fromFile:filePath];
    return task;
}

#pragma mark - Setters and getters

- (NSString *)fileName
{
    if (!_fileName)
    {
        // remove the querystring after ? if exists
        NSString *filename = [NSString stringWithString:[self.url.absoluteString lastPathComponent]];
        return [[filename componentsSeparatedByString:@"?"] firstObject];
    }
    else
        return _fileName;
}

- (NSString *)destinationDirectory
{
    if (!_destinationDirectory)
        return [[FLDownloader sharedDownloader] defaultFilePath];
    else
        return _destinationDirectory;
}

#pragma mark - public methods

/**
 Start the download. The FLDownload object is retained by the system until the download ends or fail (then the completion block is called and the object disposed)
 */
-(void)start
{
    // save the downloads (directory path, name) before starting it
    [[FLDownloader sharedDownloader] saveDownloads];
    
    // start
    [[self downloadTask] resume];
}

/**
 Cancel the download - private
 */
-(void)cancel
{
    [[FLDownloader sharedDownloader] cancelDownloadTaskForURL:self.url];
}

/**
 Cancel the download - private
 */
-(void)cancelPrivate
{
    [[self downloadTask] cancel];
}

/**
 Sends a resume or pause message to the download operation basing on the current state
 */
-(void)resumeOrPause
{
    NSURLSessionTask *task = [self downloadTask];
    
    if (task.state == NSURLSessionTaskStateRunning)
    {
        [task suspend];
    } else if (task.state == NSURLSessionTaskStateSuspended)
    {
        [task resume];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:kFLDownloadEncodedURL];
    [aCoder encodeObject:self.destinationDirectory forKey:kFLDownloadEncodedDestinationDirectory];
    [aCoder encodeInt:self.type forKey:kFLDownloadEncodedType];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initPrivate];
    if (self) {
        _url = [aDecoder decodeObjectForKey:kFLDownloadEncodedURL];
        _destinationDirectory = [aDecoder decodeObjectForKey:kFLDownloadEncodedDestinationDirectory];
        _type = [aDecoder decodeIntForKey:kFLDownloadEncodedType];
        // start
        
    }
    return self;
}

@end
