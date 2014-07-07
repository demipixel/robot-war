//
//  TheRobot.m
//  RobotWar
//
//  Created by Kevin Li on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "TheRobot.h"
#import "Bullet.h"


@implementation TheRobot {
    CGPoint _lastEnemyLocation;
    CGFloat _lastSuccessfulHit;
}

- (void)run {
    while (true) {
        if ([self currentTimestamp] - _lastSuccessfulHit > 20.f) {
            [self turnGunLeft:43.6];
            for (int i = 0; i < 5; i++) {
                [self shoot];
            }
        }
        else {
            [self aimGunAtPoint:_lastEnemyLocation];
            for (int i = 0; i < 20; i++) {
                [self shoot];
            }
            [self turnRobotLeft:arc4random() % 360];
            [self moveAhead:arc4random() % 50];
        }
    }
}

- (void)aimGunAtPoint:(CGPoint)point {
    float angleToEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:point];
    angleToEnemy > 0 ? [self turnGunRight:angleToEnemy] : [self turnGunLeft:-angleToEnemy];
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    _lastEnemyLocation = bullet.position;
    _lastSuccessfulHit = [self currentTimestamp];
}

- (void)gotHit {
    [self turnRobotLeft:arc4random() % 50];
    [self moveAhead:arc4random() % 100 + 40];
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    _lastEnemyLocation = position;
}

@end