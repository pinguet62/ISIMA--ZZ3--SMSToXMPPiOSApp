//
//  ViewController.h
//  SMSToXMPPiOSApp
//
//  Created by pinguet on 29/12/12.
//  Copyright (c) 2012 pinguet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMPPFramework.h"



@interface ViewController : UIViewController <UIApplicationDelegate, XMPPRosterDelegate>

- (IBAction)envoiXMPP:(id)sender;
- (IBAction)envoiSMS:(id)sender;

@property NSString * identifiant;
@property NSString * motdepasse;

// Méthodes liées au protocole XMPP
@property XMPPStream * xmppStream;
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (BOOL)connect;
- (void)disconnect;
- (IBAction)sendMessage;

@end
