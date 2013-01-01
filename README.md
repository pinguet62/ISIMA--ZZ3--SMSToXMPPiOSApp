SMSToXMPPiOSApp



Application XMPP :
    connexion               ok
    identification          ok
    envoi message           ok
    réception message       ok

Application SMS :
    événement réception     ok
    lecture                 -
    envoi                   ok


Configuration du projet
    Framework XMPP : XMPPFramework
        Il a besoin de frameworks standards
            Project > Target > Build Phases > Link Binary With Libraries > +
                CFNetwork.framework
                CoreData.framework
                Security.framework
                SystemConfiguration.framework
                libxml2.dylib
                libresolv.dylib
        Il est codé en ARC, il faut donc le compiler en mode "ARC"
            Project > Target > Build Phases > Compile Sources
            Pour tous les fichiers du framework, ajouter l'option "-fobjc-arc" (sans parenthèse)
            Remarque
                Lors de la compilation avec "-fobjc-arc" il est possible que certain fichier émettent des erreur.
                C'est le cas par exemple de "XMPPMessage+XEP_0224.m";
                Il suffit d'enlever cette option.
        Options de compilation
            Project > Target > Build Settings > Other Linker Flags : -lxml2
            Project > Target > Build Settings > Header Search Paths : $(SDKROOT)/usr/include/libxml2
            Project > Target > Build Settings > User Header Search Paths : /usr/include/libxml2
    Framework SMS : CoreTelephony.framework
        Inclus dans le SDK de xCode :
            Project > Target > Build Phases > Compile Sources > CoreTelephony.framework
        Certains fichiers manquent dans le framework, il suffit de les ajouter au répertoire "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.0.sdk/System/Library/Frameworks/CoreTelephony.framework/Headers/".

            
