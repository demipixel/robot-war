//
//  ProBot.m
//  RobotWar
//
//  Created by Kevin Li on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ProBot.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFighting,
    RobotStateSearching
};

@implementation ProBot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    BOOL _forward;
}

- (void)run {
    _forward = true;
    while (true) {
        if (_currentRobotState == RobotStateFighting) {
            
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
        
        if (_currentRobotState == RobotStateSearching) {
            if (_forward == true) {
                [self moveAhead:50];
            }
            else
            {
                [self moveBack:50];
            }
        }
        
        if (_currentRobotState == RobotStateDefault) {
            if (_forward == true) {
                [self moveAhead:100];
            }
            else
            {
                [self moveBack:100];
            }
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFighting) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFighting;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        
        _forward = !_forward;
        if(_forward == true)
        {
            [self moveAhead:50];
        }
        else
        {
            [self moveBack:50];
        }
        
        _currentRobotState = previousState;
    }
}

- (void)gotHit {
    //NSInteger randomDistance = (arc4random() % 50);
    //randomDistance += 80;
    if(_forward == true)
    {
        [self moveAhead:70];
    }
    else
    {
        [self moveBack:70];
    }
    _currentRobotState = RobotStateFighting;
}

@end