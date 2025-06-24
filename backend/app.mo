import Text "mo:base/Text";
import Float "mo:base/Float";
// Importez les bibliothèques nécessaires
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";

import Types "Types";
// import Shared "Shared";


// Déclarez le contrat intelligent
persistent actor class DeliveryApp() {
  Debug.print("Test Upgrade data persistance");
  Debug.print("Test Upgrade data persistance");
func key(p: Text) : Trie.Key<Text> {
  { hash = Text.hash(p); key = p }
};

  type Trie<Text, V> = Trie.Trie<Text, V>;
  type Key<Text> = Trie.Key<Text>;
  // Stockez les clients, les livreurs et les commandes de livraison

  // Pour persister les données de l'application on doit utiliser "stable" devant les variables
  // Mais puisque Hashmap est non-stable variable on utilise un autre pattern pour persister les données de l'application
  private stable var clientsEntries : [(Principal, Types.Client)] = [];
  stable var deliverersEntries : [(Principal, Types.Deliverer)] = [];
  private stable var ordersEntries : [(Text, Types.DeliveryOrder)] = [];
  private stable var notesClientsEntries : [(Principal, [Types.Note])] = [];
  private stable var notesLivreursEntries : [(Principal, [Types.Note])] = [];

  private stable var clients : Trie<Text, Types.Client> =  Trie.empty();
  private stable var deliverers : Trie<Principal, Types.Deliverer> =  Trie.empty();
  private stable var orders : Trie<Text, Types.DeliveryOrder> =  Trie.empty();

  // private var deliverers = HashMap.HashMap<Principal, Types.Deliverer>(1, Principal.equal, Principal.hash);
  // Stocker les commandes de livraison
  // private var orders = HashMap.HashMap<Text, Types.DeliveryOrder>(1, Text.equal, Text.hash);
  // private var notesClients = HashMap.HashMap<Principal, [Types.Note]>(1, Principal.equal, Principal.hash);
  // private var notesLivreurs = HashMap.HashMap<Principal, [Types.Note]>(1, Principal.equal, Principal.hash);

  public shared (msg) func whoami() : async Text {
        Principal.toText(msg.caller);
    };
  
  func keyn(t: Principal) : Key<Principal> { { hash = Principal.hash t; key = t } };
  func keyText(t: Text) : Key<Text> { { hash = Text.hash t; key = t } };

  // // ...   --------------------------------------
  // // ...                 CLIENTS
  // // ...   --------------------------------------

  // Fonction pour créer un nouveau client
  public shared ({ caller }) func createClient(client: Types.Client) : async Result.Result<(), Text> {
      switch (Trie.get(clients,key(client.clientId), Text.equal)) {
      case (null) {
        // Create it
        let clientTemp : Types.Client = {
          clientId = client.clientCNI; // Ou Caller:Principal apres integration de l'auth avec iternet Identity
          clientFirstName = client.clientFirstName;
          clientLastName = client.clientLastName;
          clientGenre = client.clientGenre;
          clientTelephone = client.clientTelephone;
          clientCNI = client.clientCNI;
          clientPasseport = client.clientPasseport;
          clientAddress = client.clientAddress;
          clientAddressLivraison = client.clientAddressLivraison;
          location = { latitude = client.location.latitude; longitude = client.location.longitude };
          dateInscription = Time.now();
          dateLastModification = Time.now();
          accountActivated = false;
          accountDeleted = false;
          notes = [];
        };

        clients := Trie.put(clients, key(client.clientId), Text.equal, clientTemp).0;
        return #ok();
        // clients.put(client.clientId, clientTemp);
        };
      case (?user) {
        return #err("Client with that CNI already exist ");
      };
    };

  };

  // Fonction interne pour obtenir un client par ID
  private func getClientById(clientId : Text) : Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal " # clientId);

      };
      case (?user) {
        return #ok(user);
      };
    };
  };

  // Fonction pour obtenir les détails d'un client
  public shared query func getClientDetails(clientId : Text) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal " # clientId);

      };
      case (?client) {
        return #ok(client);
      };
    };
  };
  // Fonction pour obtenir la position d'un client
  public shared query func getClientLocation(clientId : Text) : async Result.Result<{ latitude : Float; longitude : Float }, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal " # clientId);
      };
      case (?client) {
        return #ok(client.location);
      };
    };
  };

  // Fonction pour obtenir tous les clients
  public shared query func getClients() : async [(Text, Types.Client)] {
    Iter.toArray(Trie.iter(clients));
  };

  // Fonction pour mettre à jour address d'un client
  public shared func updateClientAddress(clientId : Text, newAddress : Text) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal" # clientId);
      };
      case (?client) {
        let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, newAddress, client.clientAddressLivraison, client.location.latitude, client.location.longitude, client.dateInscription, Time.now(), client.accountActivated, client.accountDeleted, client.notes);
        // clients.put(clientId, newInfosClient);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
        return #ok(newInfosClient);
      };
    };
  };
  // Fonction pour mettre à jour address livraison d'un client
  public shared func updateClientAddressLivraison(clientId : Text, newAddressLivraison : Text) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal" # clientId);
      };
      case (?client) {
        let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, client.clientAddress, newAddressLivraison, client.location.latitude, client.location.longitude, client.dateInscription, Time.now(), client.accountActivated, client.accountDeleted, client.notes);
        // clients.put(clientId, newInfosClient);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
        return #ok(newInfosClient);
      };
    };
  };
  // Fonction pour activer un client
  public shared func activateClient(clientId : Text) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal" # clientId);
      };
      case (?client) {
        let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, client.clientAddress, client.clientAddressLivraison, client.location.latitude, client.location.longitude, client.dateInscription, Time.now(), true, client.accountDeleted, client.notes);
        // clients.put(clientId, newInfosClient);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
        return #ok(newInfosClient);
      };
    };
  };
  // Fonction pour delete un client
  public shared func deleteClient(clientId : Text) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal" # clientId);

      };
      case (?client) {
        let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, client.clientAddress, client.clientAddressLivraison, client.location.latitude, client.location.longitude, client.dateInscription, Time.now(), client.accountActivated, true, client.notes);
        // clients.put(clientId, newInfosClient);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
        return #ok(newInfosClient);
      };
    };
  };
  // Fonction pour activer un client
  public shared func updateClientLocation(clientId : Text, lat : Float, lng : Float) : async Result.Result<Types.Client, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal" # clientId);

      };
      case (?client) {
        let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, client.clientAddress, client.clientAddressLivraison, lat, lng, client.dateInscription, Time.now(), client.accountActivated, client.accountDeleted, client.notes);
        // clients.put(clientId, newInfosClient);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
        return #ok(newInfosClient);
      };
    };
  };

  // Noter un client par un livreur donc plutard caller sera l'id du livreur
  public shared ({ caller }) func noterClient(clientId : Text, delivererId : Principal, note : Nat, commentaire : Text) : async Result.Result<Types.Note, Text> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that ID found! ");
      };
      case (?client) {
        // Get his notes
        let newNote : Types.Note = {
              noteId = Array.size(client.notes) + 1;
              clientId = clientId;
              delivererId = delivererId;
              note = note; // 1 - 5
              comment = commentaire;
              dateNote = Time.now();
            };
            let newClientNotes = Array.append<Types.Note>(client.notes, [newNote]);
            let newInfosClient : Types.Client = instanciateClient(clientId, client.clientFirstName, client.clientLastName, client.clientGenre, client.clientTelephone, client.clientCNI, client.clientPasseport, client.clientAddress, client.clientAddressLivraison, client.location.latitude, client.location.longitude, client.dateInscription, Time.now(), client.accountActivated, client.accountDeleted, newClientNotes);
        clients := Trie.put(clients, key(clientId), Text.equal, newInfosClient).0;
            return #ok(newNote);
      };
    };
  };

  // List notes d'un client
  public type NoteError = { #notFound : Text; #noNote : [Types.Note] };
  public shared query func getClientNotes(clientId : Text) : async Result.Result<[Types.Note], NoteError> {
    switch (Trie.find(clients, key(clientId), Text.equal)) {
      case (null) {
        // No client found
        return #err(#notFound("No Client with that given principal " # clientId));

      };
      case (?client) {
        return #ok(client.notes);
      };
    };
  };


  func instanciateClient(clientId : Text, clientFirstName : Text, clientLastName : Text, clientGenre : Text, clientTelephone : Text, clientCNI : Text, clientPasseport : Text, clientAddress : Text, clientAddressLivraison : Text, lat : Float, lng : Float, dateInscription : Time.Time, dateLastModification : Time.Time, accountActivated : Bool, accountDeleted : Bool, notes: [Types.Note]) : Types.Client {
    let newInfosClient : Types.Client = {
      clientId = clientId; // Ou Caller:Principal apres integration de l'auth avec iternet Identity
      clientFirstName = clientFirstName;
      clientLastName = clientLastName;
      clientGenre = clientGenre;
      clientTelephone = clientTelephone;
      clientCNI = clientCNI;
      clientPasseport = clientPasseport;
      clientAddress = clientAddress;
      clientAddressLivraison = clientAddressLivraison;
      location = { latitude = lat; longitude = lng };
      dateInscription = dateInscription;
      dateLastModification = dateLastModification;
      accountActivated = accountActivated;
      accountDeleted = accountDeleted; // Value to update
      notes = notes;
    };
    return newInfosClient;

  };

  // // ...   --------------------------------------
  // // ...                 CLIENTS
  // // ...   -------------------------------------- END

// -----------------------------------------------------------------------------------

  // // ...   --------------------------------------
  // // ...                 LIVREURS
  // // ...   --------------------------------------

  // Fonction pour créer un nouveau livreur
  public shared ({ caller }) func createDeliverer(deliverer: Types.Deliverer) : async Result.Result<(), Text> {
    switch (Trie.find(deliverers, keyn(deliverer.delivererId), Principal.equal)) {
      case (null) {
        // No client found
        let vehiculeDefault : Types.Vehicle = {
          capacity = 0;
          color = "";
          immatriculation = "";
          make = "";
          model = "";
          vehicleId = "";
          vehicleType = #Moto("moto");
          year = "";
        };
        // Create it
        let livreur : Types.Deliverer = {
          delivererId = caller;
          delivererFirstName = deliverer.delivererFirstName;
          delivererLastName = deliverer.delivererLastName;
          delivererTelephone = deliverer.delivererTelephone;
          delivererEmail = deliverer.delivererEmail;
          delivererGenre = deliverer.delivererGenre;
          delivererCNI = deliverer.delivererCNI;
          delivererPasseport = deliverer.delivererPasseport;
          delivererNumPermis = deliverer.delivererNumPermis;
          vehicule = vehiculeDefault;
          delivererAddress = deliverer.delivererAddress;
          available = false;
          location = { latitude = deliverer.location.latitude; longitude = deliverer.location.longitude };
          accountActivated = false;
          accountDeleted = false;
          profileCompleted = false;
          dateInscription = deliverer.dateInscription;
          dateLastModification = deliverer.dateLastModification;
          notes = [];
          // orders = Trie.empty();
        };

        deliverers := Trie.put(deliverers, keyn(deliverer.delivererId), Principal.equal, livreur).0;
        // deliverers.put(caller, livreur);

        return #ok();
      };
      case (?user) {
        return #err("Deliverer with that CNI already exist ");
      };
    };
  };
  // Fonction pour créer un nouveau livreur
  public shared ({ caller }) func updateDeliverer(deliverer: Types.Deliverer) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(deliverer.delivererId), Principal.equal)) {
      case (null) {
        // No Deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(deliverer.delivererId));
      };
      case (?foundDeliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(deliverer.delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, deliverer.delivererAddress, deliverer.location.latitude, deliverer.location.longitude, deliverer.accountActivated, deliverer.accountDeleted, deliverer.profileCompleted, deliverer.dateInscription, Time.now(), deliverer.available, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(deliverer.delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };

  // Fonction interne pour obtenir un livreur par ID
  private func getDelivererById(delivererId : Principal) : Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No Deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));
      };
      case (?user) {
        return #ok(user);
      };
    };
  };

  // Fonction pour obtenir les détails d'un livreur
  public shared query func getDelivererDetails(delivererId : Principal) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));

      };
      case (?deliverer) {
        return #ok(deliverer);
      };
    };
  };
  // Fonction pour obtenir la position d'un livreur
  public shared query func getDelivererLocation(delivererId : Principal) : async Result.Result<{ latitude : Float; longitude : Float }, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));
      };
      case (?deliverer) {
        return #ok(deliverer.location);
      };
    };
  };

  // Fonction pour obtenir tous les livreurs
  public shared query func getDeliverers() : async [(Principal, Types.Deliverer)] {
    Iter.toArray(Trie.iter(deliverers));
  };

  // Fonction pour mettre à jour address d'un livreur
  public shared func updateDelivererAddress(delivererId : Principal, newAddress : Text) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No Deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));
      };
      case (?deliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, newAddress, deliverer.location.latitude, deliverer.location.longitude, deliverer.accountActivated, deliverer.accountDeleted, deliverer.profileCompleted, deliverer.dateInscription, Time.now(), deliverer.available, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };

  // Fonction pour activer un livreur
  public shared func activateDeliverer(delivererId : Principal) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No livreur found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));
      };
      case (?deliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, deliverer.delivererAddress, deliverer.location.latitude, deliverer.location.longitude, true, deliverer.accountDeleted, deliverer.accountDeleted, deliverer.dateInscription, Time.now(), deliverer.available, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };
  // Fonction pour changer la disponibilité un livreur
  public shared func changeDelivererAvailability(delivererId : Principal, availability: Bool) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No livreur found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));
      };
      case (?deliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, deliverer.delivererAddress, deliverer.location.latitude, deliverer.location.longitude, deliverer.accountActivated, deliverer.accountDeleted, deliverer.accountDeleted, deliverer.dateInscription, Time.now(), availability, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };
  // Fonction pour activer un livreur
  public shared func deleteDeliverer(delivererId : Principal) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal " # Principal.toText(delivererId));

      };
      case (?deliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, deliverer.delivererAddress, deliverer.location.latitude, deliverer.location.longitude, deliverer.accountActivated, true, deliverer.profileCompleted, deliverer.dateInscription, Time.now(), deliverer.available, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };
  // Fonction pour activer un livreur
  public shared func removeDeliverer(delivererId : Principal) : async Result.Result<Text, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No client found
        return #err("No Client with that given principal " # Principal.toText(delivererId));

      };
      case (?deliverer) {
        deliverers := Trie.remove(deliverers, keyn(delivererId), Principal.equal).0;
        // TODO // Now after removing from the principal list we can put it in a removedDeliverers trie
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok("Deliverer removed from the plateform ");
      };
    };
  };
  // Fonction pour activer un client
  public shared func updateDelivererLocation(delivererId : Principal, lat : Float, lng : Float) : async Result.Result<Types.Deliverer, Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No Deliverer found
        return #err("No Deliverer with that given principal " # Principal.toText(delivererId));

      };
      case (?deliverer) {
        let newInfosDeliverer : Types.Deliverer = instanciateDelivery(delivererId, deliverer.delivererFirstName, deliverer.delivererLastName, deliverer.delivererGenre, deliverer.delivererTelephone, deliverer.delivererEmail, deliverer.delivererCNI, deliverer.delivererPasseport, deliverer.delivererNumPermis, deliverer.vehicule, deliverer.delivererAddress, lat, lng, deliverer.accountActivated, deliverer.accountDeleted, deliverer.accountDeleted, deliverer.dateInscription, Time.now(), deliverer.available, deliverer.notes);
        deliverers := Trie.put(deliverers, keyn(delivererId), Principal.equal, newInfosDeliverer).0;
        // deliverers.put(delivererId, newInfosDeliverer);
        return #ok(newInfosDeliverer);
      };
    };
  };

  // Noter un livreur par un livreur donc plutard caller sera l'id du livreur
  public shared ({ caller }) func noterDeliverer(delivererId : Principal, clientId : Principal, note : Nat, commentaire : Text) : async Result.Result<(), Text> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No livreur found
        return #err("No Deliverer with that ID found! ");
      };
      case (?deliverer) {
        // Get his notes
        // switch (notesLivreurs.get(delivererId)) {
        //   case (null) {
        //     // Pas encore de commentaires
        //     let newNote : Types.Note = {
        //       noteId = 1;
        //       delivererId = delivererId;
        //       clientId = clientId;
        //       note = note; // 1 - 5
        //       comment = commentaire;
        //       dateNote = Time.now();
        //     };
        //     notesLivreurs.put(delivererId, [newNote]);
        //     return #ok();

        //   };
        //   case (?livreurNotesBuffer) {
        //     // Il a des commentaires donc on add le new comment
        //     let newNote : Types.Note = {
        //       noteId = livreurNotesBuffer.size() + 1;
        //       delivererId = delivererId;
        //       clientId = clientId;
        //       note = note; // 1 - 5
        //       comment = commentaire;
        //       dateNote = Time.now();
        //     };
        //     let newLivreurNotesBuffer = Array.append<Types.Note>(livreurNotesBuffer, [newNote]);
        //     notesLivreurs.put(delivererId, newLivreurNotesBuffer);
        //     return #ok();
        //   };
        // };
        return #ok();
      };
    };
  };


  // List notes d'un livreur
  // public type NoteError = { #notFound : Text; #noNote : [Types.Note] };
  public shared query func getLivreursNotes(delivererId : Principal) : async Result.Result<[Types.Note], NoteError> {
    switch (Trie.find(deliverers, keyn(delivererId), Principal.equal)) {
      case (null) {
        // No client found
        return #err(#notFound("No Deliverer with that given principal " # Principal.toText(delivererId)));

      };
      case (?deliverer) {

        return #ok(deliverer.notes);
      };
    };
  };


  func instanciateDelivery(delivererId : Principal, delivererFirstName : Text, delivererLastName : Text, delivererGenre : Text, delivererTelephone : Text, delivererEmail : Text, delivererCNI : Text, delivererPasseport : Text, delivererNumPermis : Text, vehicule: Types.Vehicle, delivererAddress : Text, latitude : Float, longitude : Float, accountActivated: Bool, accountDeleted: Bool, profileCompleted: Bool,  dateInscription: Time.Time, dateLastModification : Time.Time, availability: Bool, notes: [Types.Note]) : Types.Deliverer {
    let newInfosDeliverer : Types.Deliverer = {
      delivererId = delivererId;
      delivererFirstName = delivererFirstName;
      delivererLastName = delivererLastName;
      delivererTelephone = delivererTelephone;
      delivererEmail = delivererEmail;
      delivererGenre = delivererGenre;
      delivererCNI = delivererCNI;
      delivererPasseport = delivererPasseport;
      delivererNumPermis = delivererNumPermis;
      vehicule = vehicule;
      delivererAddress = delivererAddress;
      available = availability;
      location = { latitude = latitude; longitude = longitude };
      accountActivated = accountActivated;
      accountDeleted = accountDeleted;
      profileCompleted = profileCompleted;
      dateInscription = Time.now();
      dateLastModification = Time.now();
      notes = notes;
      // orders = orders;
    };
    return newInfosDeliverer;

  };

  // // ...   --------------------------------------
  // // ...                 LIVREURS
  // // ...   -------------------------------------- END

  // Livraison functionnalities START

  // Fonction pour qu'un client passe une nouvelle commande
  // shared ({ caller}) donne accés a l'id de celui qui appelle la fonction
  public shared ({ caller : Principal }) func placeOrder(clientId : Principal, delivererId : Principal, expediteurId : Principal, recepteurId : Principal) : async Result.Result<(Text), Text> {
    // Vérifier si le client et le livreur existent
    // if ((not clientExists(clientId)) or (not delivererExists(delivererId))) {
    //   return "Client ou livreur inexistant";
    // };

    // Créer une nouvelle commande
    let orderId = generateOrderId(clientId);
    let newOrder : Types.DeliveryOrder = {
      orderId = orderId;
      expediteurId = expediteurId;
      recepteurId = recepteurId;
      delivererId = delivererId;
      deliveryStatus = #En_cours;
      coutLivraison = "2000";
      pourcentageDeliverer = "2";
      infosProduit = {
        // productId = "";
        typeProduct = "";
        fragilite = true; // [fragile, ]
        poids = ""; //poids total
        volume = ""; //volume total
        nbArticles = "";
        infosSupplementairesProduit = ""; // divers infos sur le produit
      };
      dateCommande = Time.now();
    };

    // Ajouter la nouvelle commande à la liste
    // orders.put(orderId, newOrder);

    // // Mettre à jour la liste des commandes pour le client
    // clients := updateClientOrders(clientId, newOrder);

    // // Mettre à jour la disponibilité du livreur
    // deliverers := updateDelivererAvailability(delivererId, false);

    // Retourner l'ID de la nouvelle commande
    return #ok(orderId);
  };

  // // Fonction pour mettre à jour l'état d'une commande de livraison
  // public shared func updateOrderStatus(orderId : Text, newStatus : DeliveryStatus) : async Bool {
  //   // Rechercher la commande dans la liste
  //   if (orderExists(orderId)) {
  //     // Mettre à jour l'état de la commande
  //     orders := orders.add({ orderId = orderId; deliveryStatus = newStatus });

  //     // Si la livraison est terminée, mettre à jour la disponibilité du livreur
  //     if (newStatus == Shared.DeliveryStatus.Delivered) {
  //       let delivererId = getOrderByOrderId(orderId).delivererId;
  //       deliverers := updateDelivererAvailability(delivererId, true);
  //     };

  //     return true;
  //   } else {
  //     return false;
  //   };
  // };

  // // Fonction pour obtenir les commandes d'un client
  // public query func getClientOrders(clientId : Text) : async [DeliveryOrder] {
  //   if (clientExists(clientId)) {
  //     return getClientsById(clientId).orders;
  //   } else {
  //     return [];
  //   };
  // };

  // // Fonction pour obtenir les commandes d'un livreur
  // public query func getDelivererOrders(delivererId : Text) : async [DeliveryOrder] {
  //   if (delivererExists(delivererId)) {
  //     return getDelivererById(delivererId).orders;
  //   } else {
  //     return [];
  //   };
  // };

  // // Fonction pour obtenir la localisation d'un livreur
  // public query func getDelivererLocation(delivererId : Text) : async {
  //   latitude : Float;
  //   longitude : Float;
  // } {
  //   if (delivererExists(delivererId)) {
  //     return getDelivererById(delivererId).location;
  //   } else {
  //     return { latitude = 0.0; longitude = 0.0 };
  //   };
  // };

  // // Fonction pour mettre à jour la localisation d'un livreur
  // public shared func updateDelivererLocation(delivererId : Text, newLocation : { latitude : Float; longitude : Float }) : async Bool {
  //   if (delivererExists(delivererId)) {
  //     deliverers := updateDelivererLocationInternal(delivererId, newLocation);
  //     return true;
  //   } else {
  //     return false;
  //   };
  // };

  // USERS Utils Functions


  // // Fonction interne pour vérifier si une commande existe
  // private func orderExists(orderId : Text) : Bool {
  //   // return orders.any((order) => order.orderId == orderId);
  //   return Array.find<Nat>(orders, func order = order.orderId == orderId);
  // };


  // // Fonction interne pour obtenir une commande par ID
  // private func getOrderByOrderId(orderId : Text) : DeliveryOrder {
  //   return Array.find<Nat>(orders, func order = order.orderId == orderId);
  // };

  // // Fonction interne pour générer un ID de commande unique
  private func generateOrderId(clientId : Principal) : Text {
    return Principal.toText(clientId) # "_" # Int.toText(Time.now());
    // return "Order" # Text.fromInt(Principal.now());
  };

  // Fonction interne pour mettre à jour les commandes d'un client
  // private func updateClientOrders(clientId : Text, newOrder : DeliveryOrder) : [Client] {
  //   let client = getClientsById(clientId);
  //   client.orders.add(newOrder);
  //   return client

  //   // return clients.map((client) =>
  //   //   if (client.clientId == clientId) then { client with orders = client.orders@[newOrder] } else client
  //   // );
  // };

  // // Livraison functionnalitirs END
  // ...

  stable var counter = 0;

  // Get the current count
  public  query ({ caller }) func get() : async Nat {
    Debug.print("Test Upgrade data persistance In get");
    Debug.print(Principal.toText(caller));
    counter;
  };

  // Increment the count by one
  public shared ({ caller }) func inc() : async () {
    Debug.print("Test Upgrade data persistance In add");
    Debug.print(Principal.toText(caller));
    counter += 1;
  };

  // Add `n` to the current count
  public func add(n : Nat) : async () {
    counter += n;
  };

  // Les fonctions sytems à exécuter avant chaque canister upgrade (dfx deploy) afin de persister/restaurer les données

  // var deliverers = HashMap.HashMap<Principal, Types.Deliverer>(1, Principal.equal, Principal.hash);
  //   // Stocker les commandes de livraison
  //   var orders = HashMap.HashMap<Text, Types.DeliveryOrder>(1, Text.equal, Text.hash);
  //   var notesClients = HashMap.HashMap<Text, Buffer.Buffer<Types.Note>>(1, Text.equal, Text.hash);
  //   var notesLivreurs = HashMap.HashMap<Text, Buffer.Buffer<Types.Note>>(1, Text.equal, Text.hash);

  // before upgrade (save/persiste data)
  system func preupgrade() {
    // clientsEntries := Iter.toArray(clients.entries());
    // deliverersEntries := Iter.toArray(deliverers.entries());
    // ordersEntries := Iter.toArray(orders.entries());
    // notesClientsEntries := Iter.toArray(notesClients.entries());
    // notesLivreursEntries := Iter.toArray(notesLivreurs.entries());

  };
  // after upgrade (restore data)
  system func postupgrade() {
    // clients := HashMap.fromIter(clientsEntries.vals(), 1, Principal.equal, Principal.hash);
    // deliverers := HashMap.fromIter(deliverersEntries.vals(), 1, Principal.equal, Principal.hash);
    // orders := HashMap.fromIter(ordersEntries.vals(), 1, Text.equal, Text.hash);
    // notesClients := HashMap.fromIter(notesClientsEntries.vals(), 1, Principal.equal, Principal.hash);
    // notesLivreurs := HashMap.fromIter(notesLivreursEntries.vals(), 1, Principal.equal, Principal.hash);
    // for((k: Text, val: Types.Client) in clientsEntries.vals()){
    //   clients.put(k, val);
    // }
  };
};