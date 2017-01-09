//
//  ViewController.m
//  MuPDFSample
//
//  Created by Calios on 09/01/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

#import "ViewController.h"
#import "MuDocumentController.h"
#include "common.h"

static NSString *PDFCellIdentifier = @"PDFCellIdentifier";
static void showAlert(NSString *msg, NSString *filename)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                    message:filename
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *pdfFiles;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MuPDFSample";
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadFiles:) forControlEvents:UIControlEventValueChanged];
    
    if ([self.tableview respondsToSelector:@selector(setRefreshControl:)]) {
        [self.tableview setRefreshControl:refreshControl];
    }
    else {
        [self.tableview insertSubview:refreshControl atIndex:0];
    }
}

- (void)loadFiles:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"document path: %@",documentPath);
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
    if (files && files.count > 0) {
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSString *file in files) {
            BOOL isDir;
            NSString *filePath = [documentPath stringByAppendingPathComponent:file];
            if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir/* && ([file hasSuffix:@".pdf"] || [file hasSuffix:@".PDF"])*/) {
                [tmp addObject:file];
            }
        }
        _pdfFiles = tmp;
    }
    
    [self.tableview reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pdfFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PDFCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PDFCellIdentifier];
    }
    
    cell.textLabel.text = [_pdfFiles[indexPath.row] lastPathComponent];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openDocument:_pdfFiles[indexPath.row]];
}

#pragma mark - PDF Handlers

- (void)openDocument:(NSString *)fileName
{
    dispatch_sync(queue, ^{});
    _fileName = fileName;
    _filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:fileName];
    MuDocRef *doc = [[MuDocRef alloc] initWithFilename:_filePath];
    if (!doc) {
        showAlert(@"Cannot open document", fileName);
        return;
    }
    
    if (fz_needs_password(ctx, doc->doc)) {
        [self askForPassword:@"'%@' needs a password:"];
    }
    else {
        [self onPasswordOK:doc];
    }
}

- (void)askForPassword:(NSString *)prompt
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Protected" message:[NSString stringWithFormat:prompt, _filePath.lastPathComponent] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)onPasswordOK:(MuDocRef *)doc
{
    MuDocumentController *documentVC = [[MuDocumentController alloc] initWithFilename:_fileName path:_filePath document:doc];
    [self.navigationController pushViewController:documentVC animated:YES];
}

@end
