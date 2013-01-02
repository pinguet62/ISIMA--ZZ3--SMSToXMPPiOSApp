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

- (IBAction)connecterServeurXMPP:(id)sender;
- (IBAction)envoiXMPP:(id)sender;
- (IBAction)envoiSMS:(id)sender;
- (IBAction)lireSMS:(id)sender;
- (IBAction)onButtonClick:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *message;

@property NSString * identifiant;
@property NSString * motdepasse;

// Méthodes liées au protocole XMPP
@property XMPPStream * xmppStream;
@property XMPPReconnect * xmppReconnect;
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (BOOL)connect;
- (void)disconnect;
- (IBAction)sendMessage;



@end
