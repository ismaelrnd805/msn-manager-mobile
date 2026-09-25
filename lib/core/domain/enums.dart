/// Énumérations métier partagées par toute l'application.
///
/// Chaque énumération expose un libellé français pour l'affichage.
/// Elles sont persistées en base via leur `.name` (voir converters.dart).
library;

enum Canal {
  messenger('Messenger'),
  whatsapp('WhatsApp'),
  appel('Appel'),
  sms('SMS'),
  presentiel('Présentiel'),
  autre('Autre');

  const Canal(this.label);
  final String label;
}

enum Priorite {
  basse('Basse', 0),
  normale('Normale', 1),
  haute('Haute', 2),
  urgente('Urgente', 3);

  const Priorite(this.label, this.level);
  final String label;
  final int level;
}

enum RequestStatut {
  nouvelle('Nouvelle'),
  enCours('En cours'),
  qualifiee('Qualifiée'),
  devisEnvoye('Devis envoyé'),
  convertie('Convertie'),
  enAttente('En attente client'),
  abandonnee('Abandonnée');

  const RequestStatut(this.label);
  final String label;
}

enum QuoteStatut {
  brouillon('Brouillon'),
  envoye('Envoyé'),
  accepte('Accepté'),
  refuse('Refusé'),
  expire('Expiré'),
  converti('Converti en commande');

  const QuoteStatut(this.label);
  final String label;
}

enum InvoiceStatut {
  brouillon('Brouillon'),
  envoyee('Envoyée'),
  partiellementPayee('Partiellement payée'),
  payee('Payée'),
  annulee('Annulée');

  const InvoiceStatut(this.label);
  final String label;
}

enum OrderStatut {
  enCours('En cours'),
  pretProduction('Prêt pour production'),
  enProduction('En production'),
  enValidation('En validation'),
  livree('Livrée'),
  terminee('Terminée'),
  annulee('Annulée');

  const OrderStatut(this.label);
  final String label;
}

enum PaymentMethode {
  especes('Espèces'),
  mvola('MVola'),
  orangeMoney('Orange Money'),
  airtelMoney('Airtel Money'),
  virement('Virement'),
  autre('Autre');

  const PaymentMethode(this.label);
  final String label;
}

enum TemplateCategorie {
  accueil('Accueil'),
  demandeInfo("Demande d'information"),
  presentationTarif('Présentation tarifaire'),
  devis('Devis'),
  confirmation('Confirmation'),
  demandeAcompte("Demande d'acompte"),
  paiementRecu('Réception de paiement'),
  demandeFichier('Demande de fichier'),
  validation('Validation'),
  correction('Correction'),
  relance('Relance'),
  livraison('Livraison'),
  solde('Solde'),
  remerciement('Remerciement');

  const TemplateCategorie(this.label);
  final String label;
}

enum QuestionType {
  texte('Texte court'),
  multiligne('Texte long'),
  nombre('Nombre'),
  date('Date'),
  liste('Liste de choix');

  const QuestionType(this.label);
  final String label;
}

enum TaskStatut {
  aFaire('À faire'),
  enCours('En cours'),
  terminee('Terminée');

  const TaskStatut(this.label);
  final String label;
}

enum ReminderType {
  deadline('Deadline'),
  relanceClient('Client à relancer'),
  validation('Validation'),
  acompte('Acompte'),
  solde('Solde'),
  fichierManquant('Fichier manquant'),
  inactivite('Commande inactive');

  const ReminderType(this.label);
  final String label;
}

enum UserRole {
  admin('Administrateur'),
  operateur('Opérateur');

  const UserRole(this.label);
  final String label;
}

/// Dossiers logiques d'une commande (miroir de l'arborescence PC).
enum DossierFichier {
  source('SOURCE'),
  travail('TRAVAIL'),
  corrections('CORRECTIONS'),
  final_('FINAL'),
  documents('DOCUMENTS');

  const DossierFichier(this.label);
  final String label;
}

enum ActivityAction {
  creation('Création'),
  modification('Modification'),
  suppression('Suppression'),
  paiement('Paiement'),
  validation('Validation'),
  changementStatut('Changement de statut'),
  changementTarif('Changement de tarif'),
  modificationWorkflow('Modification de workflow'),
  exceptionRegles('Exception autorisée'),
  transfertPc('Transfert vers PC'),
  synchronisation('Synchronisation'),
  connexion('Connexion');

  const ActivityAction(this.label);
  final String label;
}

enum SyncOperation {
  create('Création'),
  update('Mise à jour'),
  delete('Suppression');

  const SyncOperation(this.label);
  final String label;
}

enum SyncQueueStatut {
  enAttente('En attente'),
  enCours('En cours'),
  synchronise('Synchronisé'),
  erreur('Erreur'),
  conflit('Conflit');

  const SyncQueueStatut(this.label);
  final String label;
}

/// État global de la synchronisation affiché dans l'interface.
enum SyncStatus {
  synchronise('SYNCHRONISÉ'),
  enCours('SYNCHRONISATION EN COURS'),
  erreur('ERREUR DE SYNCHRONISATION'),
  online('ONLINE'),
  offline('OFFLINE'),
  nonConfigure('SERVEUR NON CONFIGURÉ');

  const SyncStatus(this.label);
  final String label;
}
