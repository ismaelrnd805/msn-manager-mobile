// Bibliothèque partagée MSN Manager V1 : shell adaptatif, écrans et providers.
// Utilisée par apps/mobile (Android) et apps/desktop (Windows).
library msn_ui;

export 'app.dart';
export 'plateforme.dart' show isMobile, plateformeCourante;
export 'state/providers.dart'
    show
        bootstrapProvider,
        baseDeDonneesProvider,
        urlServeurProvider,
        jetonProvider,
        appareilIdProvider,
        apiPortProvider,
        syncMoteurProvider,
        etatSyncProvider,
        synchroniser;
export 'state/tableaux_bord.dart' show resumeTableauBordProvider;
export 'ui/screens/accueil.dart';
export 'ui/screens/catalogue.dart';
export 'ui/screens/clients.dart';
export 'ui/screens/commandes.dart';
export 'ui/screens/communications.dart';
export 'ui/screens/demandes.dart';
export 'ui/screens/devis.dart';
export 'ui/screens/facebook_planning.dart';
export 'ui/screens/finances.dart';
export 'ui/screens/journal_audit.dart';
export 'ui/screens/parametres.dart';
export 'ui/screens/taches.dart';
