//
//  ViewController.m
//  SMSToXMPPiOSApp
//
//  Created by pinguet on 29/12/12.
//  Copyright (c) 2012 pinguet. All rights reserved.
//

#import "ViewController.h"

#import <CoreTelephony/CTMessageCenter.h>

// Alertes SMS
#import <ChatKit/CKSMSService.h>
#include "dlfcn.h"

id (* CTTelephonyCenterGetDefault)();
void (* CTTelephonyCenterAddObserver)(id, id, CFNotificationCallback, NSString *, void *, int);

static void telephonyEventCallback(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    NSString * notifyname = (NSString *) CFBridgingRelease(name);
    if ([notifyname isEqualToString:@"kCTMessageReceivedNotification"]) {
        NSLog(@"SMS reçu !!!");
    }
}



@interface ViewController ()

@end



@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"initWithNibName");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _identifiant = @"pinguet62test@gmail.com";
        _motdepasse = @"AZE123qsd";
        _xmppStream = [[XMPPStream alloc] init];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    void * uikit = dlopen("/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.0.sdk/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    CTTelephonyCenterGetDefault = dlsym(uikit, "CTTelephonyCenterGetDefault");
    CTTelephonyCenterAddObserver = dlsym(uikit, "CTTelephonyCenterAddObserver");
    dlclose(uikit);
    id ct = CTTelephonyCenterGetDefault();
    CTTelephonyCenterAddObserver(ct, NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)dealloc {
    NSLog(@"dealloc");
    
    [_xmppStream release];
    [_xmppReconnect release];
    [super dealloc];
}



#pragma mark Méthodes de l'application

- (IBAction)connecterServeurXMPP:(id)sender {
    NSLog(@"connecterServeurXMPP");
    
    [self connect];
}



- (IBAction)envoiXMPP:(id)sender {
    NSLog(@"envoiXMPP");
    
    [self sendMessage];
}



- (IBAction)envoiSMS:(id)sender {
    NSLog(@"envoiSMS");
    
    [[CTMessageCenter sharedMessageCenter] sendSMSWithText:@"test" serviceCenter:nil toAddress:@"0647618122"];
}



#pragma mark XMPP Methodes

- (void)setupStream {
    NSLog(@"setupStream");
    
    _xmppStream = [[XMPPStream alloc] init];
    #if !TARGET_IPHONE_SIMULATOR
    {
		_xmppStream.enableBackgroundingOnSocket = YES;
	}
    #endif
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Gestion des déconnexions
    _xmppReconnect = [[XMPPReconnect alloc] init];
	[_xmppReconnect activate:_xmppStream];
}



#pragma mark XMPP Online/offline

- (void)goOnline {
    NSLog(@"goOnline");
    
    XMPPPresence * presence = [XMPPPresence presence]; // == presenceWithType:@"available"
    [[self xmppStream] sendElement:presence];
}



- (void)goOffline {
    NSLog(@"goOffline");
    
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}



#pragma mark XMPP Connect/disconnect

- (BOOL)connect {
    NSLog(@"connect");
    
    // Configuration
    [self setupStream];
    
    // Encore connecté
    if (! [_xmppStream isDisconnected]) {
        return YES;
    }
    
    // Identifiant
    XMPPJID * jidIdentifiant = [XMPPJID jidWithString:_identifiant];
    [_xmppStream setMyJID:jidIdentifiant];
    
    // Connexion
    NSError * error = nil;
    if (! [_xmppStream connect:&error]) {
        NSLog(@"Echec de la connexion : %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}



- (void)disconnect {
    NSLog(@"Déconnexion");
    
    [self goOffline];
    [_xmppStream disconnect];
}



#pragma mark XMPP Delegates

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidConnect");
    
    NSError * error = nil;
	if (! [_xmppStream authenticateWithPassword:_motdepasse error:&error])
		NSLog(@"Echec d'authentification : %@", error);
}



- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidAuthenticate");
    
    [self goOnline];
}



- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"xmppStream didReceiveMessage");
    
    NSString * from = [[message attributeForName:@"from"] stringValue];
    NSString * msg = [[message elementForName:@"body"] stringValue];
    NSLog(@"from : %@ - msg : %@", from, msg);
}



- (IBAction)sendMessage {
    NSLog(@"sendMessage");
    
    NSXMLElement * message = [NSXMLElement elementWithName:@"message"];
    // Type
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    // Destinataire
    [message addAttributeWithName:@"to" stringValue:@"pinguet62@gmail.com"];
    // Corps
    NSXMLElement * body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"test d'envoi"];
    [message addChild:body];
    
    [_xmppStream sendElement:message];
}

@end
