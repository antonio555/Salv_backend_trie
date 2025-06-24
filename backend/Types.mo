import Time "mo:base/Time";
// import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
module Types {

      // Déclarez la structure de données pour un client
  public type Client = {
    clientId : Text;
    clientFirstName : Text;
    clientLastName : Text;
    clientGenre : Text;
    clientTelephone : Text;
    clientCNI : Text;
    clientPasseport : Text;
    clientAddress : Text;
    clientAddressLivraison : Text;
    location : { latitude : Float; longitude : Float };
    //orders : Trie.Trie<Nat, DeliveryOrder>; // à exploiter pour de futures réductions
    notes : [Note];
    accountActivated : Bool;
    accountDeleted : Bool;
    dateInscription : Time.Time;
    dateLastModification : Time.Time;
  };

  public type Note = {
    noteId : Nat;
    clientId : Text;
    delivererId : Principal;
    note : Nat; // 1 - 5
    comment : Text;
    dateNote : Time.Time;
  };

  // Déclarez la structure de données pour un livreur avec la localisation et ses notes (recues des clients)
  // Pieces a fournir pour les livreurs
  // Certificat de residence - CNI legalisee - Casier judiciaire de moins de 3 moins - extrait de naissance -3mois
  // Certificat de bonne vie et moeursS

  // Alleger l'inscription et prendre juste une photo CNI

  // Valider le compte en integrant le scan de tous les docs
  public type VehicleType = {
    #Pickup: Text;
    #Camionnette: Text;
    #Fourgonnette: Text;
    #Demenageur: Text;
    #Moto: Text;
    #Tricycle: Text;
  };
  // vehicule type
  // vehicleType: // declarer type de donnees type vehicule
  public type Vehicle = {
    vehicleId : Text;
    make : Text;
    model : Text;
    immatriculation : Text; // verification d'immat
    year : Text;
    color : Text;
    capacity : Float; // en KG
    vehicleType : VehicleType;
    // Photos 1 - 5
  };
  public type Deliverer = {
    delivererId : Principal;
    delivererFirstName : Text;
    delivererLastName : Text;
    delivererTelephone : Text;
    delivererEmail : Text;
    delivererGenre : Text;
    delivererCNI : Text;
    delivererPasseport : Text;
    delivererNumPermis : Text;
    vehicule : Vehicle; // prévoir la possibilité d'avoir plusieurs vehicules
    delivererAddress : Text;
    available : Bool; // disponibilite du livreur / choisir sa disponibilité juste apres la connexion
    location : { latitude : Float; longitude : Float };
    accountActivated : Bool;
    accountDeleted : Bool;
    profileCompleted : Bool;
    dateInscription : Time.Time;
    dateLastModification : Time.Time;
    // orders : Trie.Trie<Nat, DeliveryOrder>; // à exploiter pour de futures réductions
    notes : [Note]

  };

  // Déclarez la structure de données pour une commande de livraison
  public type ProductOrder = {
    // productId : Principal;
    typeProduct : Text;
    fragilite : Bool; // [fragile, ]
    poids : Text; //poids total
    volume : Text; //volume total
    nbArticles : Text;
    infosSupplementairesProduit : Text; // divers infos sur le produit
  };
  // Déclarez la structure de données pour une commande de livraison
  public type DeliveryStatus = {
    #En_cours;
    #Recherche_livreur;
    #Livree;
  };
  public type DeliveryOrder = {
    orderId : Text;
    expediteurId : Principal; //expediteur
    recepteurId : Principal; //recepteur
    infosProduit : ProductOrder;
    delivererId : Principal;
    deliveryStatus : DeliveryStatus; // recherche de livreur , en cours de livraison, livrée,
    coutLivraison : Text;
    pourcentageDeliverer : Text;
    dateCommande : Time.Time; // Timestamp
    // représenter un tableau de lat lng pour la trajectoire suivie par le livreur
  };
}