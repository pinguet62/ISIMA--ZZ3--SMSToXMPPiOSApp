//
//  ViewController.m
//  SMSToXMPPiOSApp
//
//  Created by pinguet on 29/12/12.
//  Copyright (c) 2012 pinguet. All rights reserved.
//

#import "ViewController.h"

#import <CoreTelephony/CTMessageCenter.h>


// Lecture des SMS
// sqlite3 /var/mobile/Library/SMS/sms.db "UPDATE msg_group set unread_count=0 where unread_count > 0";

#import <sqlite3.h>

NSString * mostRecentSMS() {
    /*NSError * erreur = nil;
    
    //NSString * fichier = [NSString stringWithContentsOfURL:cheminURL encoding:NSUTF8StringEncoding error:&erreur];
    //NSLog(@"fichier : %@", fichier);
    
    [[NSFileManager defaultManager] copyItemAtPath:@"/var/mobile/Library/SMS/sms.db" toPath:@"/var/tmp/sms.db" error:&erreur];
    
    NSLog(@"erreur : %@", erreur);
    
    system("cp /private/var/mobile/Library/SMS/sms.db /var/tmp/sms.db");*/
    
    
    
    NSString * text = @"";
    
    //const char * filename = "/private/var/mobile/Library/SMS/sms.db";
    const char * filename = "/var/tmp/sms.db";
    //const char * filename = "/var/mobile/Documents/sms.db";
    sqlite3 * database;
    if (sqlite3_open(filename, &database) == SQLITE_OK) {
        const char * strRequete = "SELECT text FROM message ORDER BY date DESC LIMIT 1";
        sqlite3_stmt * compRequete;
        if (sqlite3_prepare_v2(database, strRequete, -1, &compRequete, NULL) == SQLITE_OK) {
            if (sqlite3_step(compRequete) == SQLITE_ROW) {
                char * content = (char *) sqlite3_column_text(compRequete, 0);
                text = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
            } else {
                NSLog(@"Erreur sqlite3_step() : %s", sqlite3_errmsg(database));
            }
            
            sqlite3_finalize(compRequete);
        } else {
            NSLog(@"Erreur sqlite3_prepare_v2() : %s", sqlite3_errmsg(database));
        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Erreur sqlite3_open() : %s", sqlite3_errmsg(database));
    }

    return text;
}



// Alertes SMS
#import <ChatKit/CKSMSService.h>
#include "dlfcn.h"

id (* CTTelephonyCenterGetDefault)();
void (* CTTelephonyCenterAddObserver)(id, id, CFNotificationCallback, NSString *, void *, int);

static void telephonyEventCallback(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    NSString * notifyname = (NSString *) CFBridgingRelease(name);
    if ([notifyname isEqualToString:@"kCTMessageReceivedNotification"]) {
        NSLog(@"SMS reçu : %@", mostRecentSMS());
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
    
    // Evénements SMS
    void * uikit = dlopen("/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.0.sdk/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    CTTelephonyCenterGetDefault = dlsym(uikit, "CTTelephonyCenterGetDefault");
    CTTelephonyCenterAddObserver = dlsym(uikit, "CTTelephonyCenterAddObserver");
    dlclose(uikit);
    id ct = CTTelephonyCenterGetDefault();
    CTTelephonyCenterAddObserver(ct, NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    //NSLog(@"Dernier SMS : %@", mostRecentSMS()); // tmp
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)dealloc {
    NSLog(@"dealloc");
    
    [_xmppStream release];
    [_xmppReconnect release];
    [_message release];
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



- (IBAction)lireSMS:(id)sender {
    NSLog(@"lireSMS");
    
    NSLog(@"Dernier SMS : %@", mostRecentSMS());
}



- (IBAction)onButtonClick:(id)sender {
    NSLog(@"onButtonClick");
    
    #ifdef JAILBREAK
    NSLog(@"oui");
    #else
    NSLog(@"non");
    #endif
    
    
    NSError * erreur = nil;
    /*[[NSFileManager defaultManager] copyItemAtPath:@"/var/mobile/Library/SMS/sms.db" toPath:@"/var/tmp/sms.db" error:&erreur];
    [[self message] setText:[NSString stringWithFormat:@"%@", erreur]];
    NSLog(@"%@", erreur);*/
    
    NSLog(@"%d", [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/mobile/Library/SMS"]);
    system("cp -f /private/var/mobile/Library/SMS/sms.db /var/tmp/mesSMS.db");
    NSLog(@"%d", [[NSFileManager defaultManager] fileExistsAtPath:@"/var/tmp/mesSMS.db"]);
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

- (void)viewDidUnload {
    [self setMessage:nil];
    [super viewDidUnload];
}
@end
