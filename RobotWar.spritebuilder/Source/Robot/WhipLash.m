//
//  WhipLash.m
//  RobotWar
//
//  Created by Tolga Beser on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import "WhipLash.h"
#import "Robot.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
    
    
};


int secondEnemyHealth = 20;
int secondHeroHealth = 20;

@implementation WhipLash {
    
    CCLabelTTF *_BM;
    
    
    
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    
    
    
    
}
-(void)run {
    while (true) {
        
        if (_currentRobotState == RobotStateFiring) {
            
            
           // NSLog(@"State is firing");
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
            
            
        }
        
        
        
        while (_currentRobotState == RobotStateSearching) {
            [self findEnemy];
            //NSLog(@"State is searching");
        }
        
        if (_currentRobotState == RobotStateDefault) {
            //NSLog(@"State is default");
            _currentRobotState = RobotStateSearching;
            
            
            
        }
        
        
        
    }
}


-(void)findEnemy {
    [self moveAhead:150];
    [self turnRobotRight:45];
    
    
    
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
    
    
}



- (void)bulletHitEnemy:(Bullet *)bullet {
    secondEnemyHealth--;
    
}

- (void)gotHit {
    secondHeroHealth--;
    
}



@end

