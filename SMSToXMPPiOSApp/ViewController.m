//
//  ViewController.m
//  SMSToXMPPiOSApp
//
//  Created by pinguet on 29/12/12.
//  Copyright (c) 2012 pinguet. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end



@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"initWithNibName");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _identifiant = @"pinguet62testgmail.com";
        _motdepasse = @"AZE123qsd";
        _xmppStream = [[XMPPStream alloc] init];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)dealloc {
    //[_identifiant release];
    //[_motdepasse release];
    [_xmppStream release];
}



//////////////////////////////////////////////////
// Méthodes de l'application
//////////////////////////////////////////////////

- (IBAction)envoiXMPP:(id)sender {
    NSLog(@"envoiXMPP");
    
    [self connect];
    [self sendMessage];
}



- (IBAction)envoiSMS:(id)sender {
    NSLog(@"envoiSMS");
    
    // TODO
}



//////////////////////////////////////////////////
// Méthodes du protocole XMPP
//////////////////////////////////////////////////

- (void)setupStream {
    NSLog(@"setupStream");
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}



- (void)goOnline {
    NSLog(@"goOnline");
    
    XMPPPresence * presence = [XMPPPresence presence]; // = presenceWithType:@"available"
    [[self xmppStream] sendElement:presence];
}



- (void)goOffline {
    NSLog(@"goOffline");
    
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}



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



//////////////////////////////////////////////////
// Evénements du protocole XMPP
//////////////////////////////////////////////////

#pragma mark XMPP delegates

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
    [message addAttributeWithName:@"to" stringValue:@"pinguet62gmail.com"];
    // Corps
    NSXMLElement * body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"test d'envoi"];
    [message addChild:body];
    
    [_xmppStream sendElement:message];
}

@end
