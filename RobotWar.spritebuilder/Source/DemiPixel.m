//
//  DemiPixel.m
//  RobotWar
//
//  Created by Kevin Li on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DemiPixel.h"
#import "GameConstants.h"
#import "Robot.h"
#import "Robot_Framework.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateSearching,
    RobotStateRapidFire,
    RobotStateShootAndRun,
    RobotStateEscape
};

@implementation DemiPixel {
    RobotState _currentState;
    
    CGPoint _lastEnemyPosition;
    CGFloat _lastDetectedTime;
    CGFloat _lastHitTime;
    
    NSInteger _hitStreak;
    
    int hitCount;
    
    BOOL rapidFireLeft;
    
    int enemyHealth;
    int health;
    
    float searchAmount;
    bool searchLeft;
    bool moveLeft;
    
    CCNodeColor *_enemyLocation;
    CCNodeColor *_ourLastLocation;
}

const bool LOG = TRUE; // Everything
const bool LOG_STATE = TRUE;
const bool LOG_STREAK = FALSE;
const bool LOG_NEW_LOCATION = FALSE;

- (void)run {
    searchAmount = 0;
    hitCount = 0;
    enemyHealth = 20;
    health = 20;
    _currentState = RobotStateSearching;
    searchLeft = true;
    [self logChange];
    _enemyLocation = [CCNodeColor nodeWithColor:[CCColor greenColor] width:10.f height:10.f];
    _ourLastLocation = [CCNodeColor nodeWithColor:[CCColor orangeColor] width:10.f height:10.f];
    [[self.robotNode parent] addChild:_ourLastLocation];
    [[self.robotNode parent] addChild:_enemyLocation];
    
    [self turnGunRight:25];
    for (int i = 0; i < 3; i++) {
        [self shoot];
        [self turnGunRight:10];
    }
    
    while (true) {
        
        [_enemyLocation setPosition:_lastEnemyPosition];
        
        if (_currentState != RobotStateSearching) searchAmount = 0;
        
        if (_currentState != RobotStateSearching && [self currentTimestamp] - _lastDetectedTime > 8.f) {
            _currentState = RobotStateSearching;
            searchLeft = !searchLeft;
            [self logChange];
            _hitStreak = 0;
        }
        
        if (_currentState == RobotStateShootAndRun) {
            if (_hitStreak >= 4) {
                _currentState = RobotStateRapidFire;
                [self logChange];
            }
            //[self cancelActiveAction];
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            int width = self.robotBoundingBox.size.width;
            if (enemyHealth - 1 > health) {
                moveLeft ? [self moveBack:width * 2] : [self moveAhead:width * 2];
            }
        }
        else if (_currentState == RobotStateRapidFire) {
            [self cancelActiveAction];
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            if (enemyHealth > health) {
                _currentState = RobotStateShootAndRun;
                [self logChange];
                _hitStreak = 0;
            }
            
            else {
                //                if (rapidFireLeft) {
                //                    [self turnGunLeft:10];
                //                    rapidFireLeft = false;
                //                }
                //                else {
                //                    [self turnGunRight:10];
                //                    rapidFireLeft = true;
                //                }
                [self cancelActiveAction];
                [self aimGunAtPoint:_lastEnemyPosition];
                [self shoot];
            }
        }
        else if (_currentState == RobotStateSearching) {
            
            
            if (searchAmount <= 40) { [self turnGunSearchDirection:15]; searchAmount += 15; }
            if (searchAmount < 360 && searchAmount > 40) { [self turnGunSearchDirection:30]; searchAmount += 30; }
            if (searchAmount >= 360 && searchAmount < 720) { [self turnGunSearchDirection:15]; searchAmount += 15; }
            if (searchAmount >= 720) [self turnGunSearchDirection:5];
            [self shoot];
        }
        else if (_currentState == RobotStateEscape) {
            int width = self.robotBoundingBox.size.width;
            int turnAngle = [self angleBetweenHeadingDirectionAndWorldPosition:_lastEnemyPosition] - 30;
            turnAngle > 0 ? [self turnRobotRight:turnAngle] : [self turnRobotLeft:-turnAngle];
            
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            
            [self moveBack:width*8];
            if (health > enemyHealth) {
                _currentState = RobotStateShootAndRun;
            }
        }
    }
}

- (void)turnGunSearchDirection:(int)amt {
    if (searchLeft) [self turnGunLeft:amt];
    else [self turnGunRight:amt];
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    [_ourLastLocation setPosition:[self robotNode].position];
    _lastEnemyPosition = position;
    if (LOG && LOG_NEW_LOCATION) NSLog(@"New Enemy Location");
    //if (health < enemyHealth) { _currentState = RobotStateEscape; [self logChange]; }
    _lastDetectedTime = [self currentTimestamp];
    if (_currentState == RobotStateSearching) {
        _currentState = RobotStateShootAndRun;
    }
    if (abs(position.x - [self robotNode].position.y) < 50 &&
        abs(position.y - [self robotNode].position.y) < 50) {
        [self logChange];
    }
}

- (void)logChange {
    if (LOG && LOG_STATE) {
        switch (_currentState) {
            case RobotStateRapidFire: NSLog(@"Rapid Fire"); break;
            case RobotStateShootAndRun: NSLog(@"Shoot and Run"); break;
            case RobotStateSearching: NSLog(@"Searching"); break;
            case RobotStateEscape: NSLog(@"Escape"); break;
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    enemyHealth--;
    //if (health > enemyHealth) { _hitStreak = 2; [self cancelActiveAction]; } // Go to Rapid Fire
    _lastEnemyPosition = bullet.position;
    if (LOG && LOG_NEW_LOCATION) NSLog(@"New Enemy Location");
    _lastDetectedTime = [self currentTimestamp];
    _hitStreak++;
    if (LOG && LOG_STREAK) NSLog(@"Hit Streak: %ld",(long)_hitStreak);
    _lastHitTime = [self currentTimestamp];
    if (_currentState == RobotStateSearching) {
        _currentState = RobotStateShootAndRun;
        [self logChange];
        searchLeft = !searchLeft;
    }
}

- (void)aimGunAtPoint:(CGPoint)point {
    float angleToEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:point];
    angleToEnemy > 0 ? [self turnGunRight:angleToEnemy] : [self turnGunLeft:-angleToEnemy];
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle {
//    if (hitAngle >= 0) {
//        [self turnRobotLeft:abs(hitAngle/1.5)];
//    }
//    else {
//        [self turnRobotRight:abs(hitAngle/1.5)];
//    }
//    [self moveAhead:30];
//    switch (hitDirection) {
//        case RobotWallHitDirectionFront:
//            [self turnRobotRight:100];
//            break;
//        case RobotWallHitDirectionRear:
//            [self turnRobotRight:100];
//            break;
//        case RobotWallHitDirectionLeft:
//            [self turnRobotRight:100];
//            [self moveAhead:20];
//            break;
//        case RobotWallHitDirectionRight:
//            [self turnRobotRight:100];
//            [self moveAhead:20];
//            break;
//        default:
//            break;
//    }
    [self cancelActiveAction];
    /*if (self.robotBoundingBox.origin.x < [UIScreen mainScreen].bounds.size.width / 2) {
        [self moveBack:50];
    }
    else {
        [self moveAhead:50];
    }*/
    moveLeft = !moveLeft;
    int width = self.robotBoundingBox.size.width;
    moveLeft ? [self moveBack:width * 2.5] : [self moveAhead:width * 2.5];
}

- (void)turnToAngle:(float)angle {
    if (LOG) NSLog(@"Move to angle %f",angle);
    float oppositeAngle = [self positiveAngle:angle - 180];
    if (self.robotNode.rotation < angle < oppositeAngle) {
        [self turnRobotLeft:angle];
    }
    else {
        [self turnRobotRight:angle];
    }
}

- (void)gotHit {
    hitCount++;
    health--;
    int width = self.robotBoundingBox.size.width;
    // [self cancelActiveAction];
    if (_currentState != RobotStateRapidFire && (hitCount >= 2 || health == 1)) {
        hitCount = 0;
        [self cancelActiveAction];
        if (self.robotBoundingBox.origin.x < [UIScreen mainScreen].bounds.size.width / 2) {
            [self moveBack:50];
        }
        else {
            [self moveAhead:50];
        }
        
    }
    if (_currentState == RobotStateRapidFire && health != enemyHealth) {
        _hitStreak -= 1;
        if (_hitStreak < 0) _hitStreak = 0;
        if (LOG && LOG_STREAK) NSLog(@"Hit Streak: %ld",(long)_hitStreak);
    }
    if (_currentState == RobotStateSearching) { _currentState = RobotStateShootAndRun; [self cancelActiveAction]; }
}

- (float)angleForX:(float)x y:(float)y {
    float angle = atan(y/x) * 180 / M_PI;
    
    if (x > 0 ^ y > 0) {
        angle = -angle;
    }
    
    return angle;
}

- (float)positiveAngle:(float)angle {
    if (angle >= 0) {	//Angle is already positive
        return angle;
    }
    return 360 - abs(angle);
}


@end