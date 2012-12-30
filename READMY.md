SMSToXMPPiOSApp

Application XMPP :
- connexion
- identification (jid, mdp)
- envoi message
- réception message

Application SMS :
- événement réception
- lecture
- envoi


Configuration du projet :
    Options du mode ARC :
        Project > Build Phases > Compile Sources
	Pour tous les fichiers du framework, sauf XMPPMessage+XEP_0224.m, ajouter l'option -fobjc-arc
    Frameworks :
        SystemConfiguration.framework
	CFNetwork.framework
	Security.framework
	CoreData.framework
	libxml2.dylib
	libresolv.dylib
    Headers :
	Project > Build Settings
	Other Linker Flags : -lxml2
	Header Search Paths : $(SDKROOT)/usr/include/libxml2
	User Header Search Paths : /usr/include/libxml2



