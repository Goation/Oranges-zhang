//
//  ViewController.m
//  MNMusic
//
//  Created by qingyun on 16/4/7.
//  Copyright © 2016年 zhang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
@property (weak, nonatomic) IBOutlet UILabel *time;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic,strong) NSArray *musicArray;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic) NSInteger index;
@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIImageView *xuehua;
@property (nonatomic) CGFloat angle;
@end

@implementation ViewController
-(AVAudioPlayer *)player
{
    if (_player == nil) {
        [self playMusic];
    }
    return _player;
}
-(NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(upUI) userInfo:nil repeats:YES];
    }
    return _timer;
}
-(NSArray *)musicArray
{
    if (_musicArray == nil) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"music" ofType:@"plist"];
        _musicArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _musicArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTable];
}
- (IBAction)clickButton:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            self.index--;
            if (self.index < 0) {
                self.index = self.musicArray.count -1;
            }
            self.player = nil;
            self.musicName.text = self.musicArray[self.index];
        }
            break;
        case 2:
        {
            if (self.player.isPlaying) {
                [self.player pause];
                [self.playButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
            }else
            {
                self.player.currentTime = self.slider.value;
                //[self playMusic];
                [self.player play];
                [self.playButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
                [self xuehuaImage];
            }
            //调用NSTimer
            self.timer.fireDate = [NSDate distantPast];
        }
            break;
        case 3:
        {
            self.index++;
            if (self.index == self.musicArray.count) {
                self.index = 0;
            }
            self.player = nil;
            self.musicName.text = self.musicArray[self.index];
        }
            break;
        default:
            break;
    }
}
-(void)playMusic
{
    [self initMusic];
    //设置播放时间的最大值
    self.slider.maximumValue = self.player.duration;
}
-(void)setSession
{
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    NSError *error;
    [avSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    NSLog(@"session error%@",error);
    [avSession setActive:YES error:nil];
}
//初始化player
-(void)initMusic
{
    if (self.musicName.text != nil) {
        NSString *url = [[NSBundle mainBundle]pathForResource:self.musicArray[self.index] ofType:@"mp3"];
        NSError *error;
        NSData *data = [[NSFileManager defaultManager]contentsAtPath:url];
        self.player = [[AVAudioPlayer alloc]initWithData:data error:&error];
        NSLog(@"error===%@",error);
        self.player.enableRate = YES;
        self.player.delegate = self;
        //初始化硬件准备
        [self.player prepareToPlay];
        //设置会话模式
        [self setSession];
    }
}
-(void)setTable
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)upUI
{
    self.slider.value = self.player.currentTime;
    NSLog(@"slider:%f",self.slider.value);
}
//通过slider的值更改音乐进度
- (IBAction)sliderClick:(UISlider *)sender {
    self.player.currentTime = sender.value;
}
//旋转
-(void)xuehuaImage
{
    [UIView animateWithDuration:0.15 animations:^{
        NSLog(@"time%f",self.player.duration);
        self.xuehua.transform = CGAffineTransformMakeRotation(self.angle*(M_PI / 180.0f));
    } completion:^(BOOL finished) {
        self.angle += 8;
        [self xuehuaImage];
    }];
}
#pragma mark -UITableViewDataSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.musicArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifter = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifter];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifter];
    }
    
    cell.textLabel.text = self.musicArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.musicName.text = self.musicArray[indexPath.row];
    [self.playButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    //这里为什么修改index的值？
    //是因为，当选择列表中的某一个cell时，当前播放器需重新初始化当前选中的歌曲
    self.index = indexPath.row;
    self.player = nil;
}
@end
