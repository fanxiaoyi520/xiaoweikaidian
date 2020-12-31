//
//  ZFPreviewImageController.m
//  Agent
//
//  Created by 中付支付 on 2018/9/19.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFPreviewImageController.h"
#import "ZFPreviewCell.h"

@interface ZFPreviewImageController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIView *navBackView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *deleteImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

///进来先显示
@property (nonatomic, strong)UIView *backView;

@end

@implementation ZFPreviewImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];

    [self firstShowView];
    if (_isHiddenDelete) {
        _deleteImageView.hidden = YES;
        _deleteBtn.hidden = YES;
    }
}

- (void)firstShowView{
    if (_index == 0) {
        return;
    }
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _backView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_backView];
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)createView{
    UICollectionViewFlowLayout *titleFlowLayout = [[UICollectionViewFlowLayout alloc]init];
    titleFlowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    titleFlowLayout.minimumInteritemSpacing = 0;
    titleFlowLayout.minimumLineSpacing = 0;
    titleFlowLayout.scrollDirection = 1;
    titleFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0 , 0, 0);
    
    _collectionView.collectionViewLayout = titleFlowLayout;
    [_collectionView registerClass:[ZFPreviewCell class] forCellWithReuseIdentifier:@"ZFPreviewCell"];
    [self.view addSubview:_navBackView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupValue];
    _backView.hidden = YES;
}

- (void)setupValue{
    _titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", _index+1, _imageArray.count];
    _collectionView.contentOffset = CGPointMake(SCREEN_WIDTH*_index, _collectionView.y);
}

- (IBAction)backBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteBtn:(id)sender {
    if (_index < _imageArray.count) {
        [_imageArray removeObjectAtIndex:_index];
        self.block(_index);
        if (_imageArray.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (_index > 0) {
            _index -= 1;
        }
        
        [_collectionView reloadData];
        [self setupValue];
    }
}

#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZFPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFPreviewCell" forIndexPath:indexPath];
    if (indexPath.row < _imageArray.count) {
        if (_isURL) {
            cell.urlString = _imageArray[indexPath.row];
        } else {        
            cell.image = _imageArray[indexPath.row];
        }
        cell.imageView.tag = indexPath.row;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [cell.imageView addGestureRecognizer:tap];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_collectionView.contentOffset.x < -80) {
//        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == _collectionView) {
        DLog(@"%f", _collectionView.contentOffset.x);
        _index = _collectionView.contentOffset.x/SCREEN_WIDTH;
        _titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", _index+1, _imageArray.count];
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    DLog(@"tag = %zd", tag);
//    if (_navBackView.isHidden) {
//        _navBackView.hidden = NO;
//    } else {
//        _navBackView.hidden = YES;
//    }
    [self.navigationController popViewControllerAnimated:YES];
    _index = tag;
    _titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", _index+1, _imageArray.count];
}

@end
