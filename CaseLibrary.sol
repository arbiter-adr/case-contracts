library CaseLibrary {

    struct Opinion {
        address[] arbitrators;
        string opinion;
    }

    struct ClaimResponse {
        bytes32 claimID;
        uint amountPaid;
        uint counterSettlementValue;
        uint dateResponded;
        uint dateReceived;
        bool accepted;
    }

    struct Party {
        address primaryContract;
        address[] members;
        mapping(address => bool) isMember;
    }

    struct Document {
        string title;
        string ipfsHash;
        uint dateAdded;
        uint docID;
    }

    struct Claim {
        string description;
        uint desiredSettlementValue;
        bytes32 status;
        uint dateIssued;
        uint dateAmended;
        uint dateDecided;
        uint amountPaid;
        bool acknowledged;
    }

    struct Data {
        Document[] documents;
        Party originatingParties;
        Party opposingParties;
        mapping(bytes32 => Claim) claims;
        bytes32[] claimIDs;
        mapping(bytes32 => ClaimResponse[]) responses;
        mapping(bytes32 => mapping(address => uint)) penalties;
    }

    function newClaim(Data storage self, string _description, uint _desiredSettlementValue) internal returns(bool){
        Claim memory c;
        c.description = _description;
        c.desiredSettlementValue = _desiredSettlementValue;
        c.dateIssued = now;
        c.amountPaid = 0;
        c.status = bytes32('pending');
        bytes32 id = sha3(c.description, c.dateIssued);

        self.claimIDs.push(id);
        self.claims[id] = c;
        return true;
    }

    function respondToClaim(Data storage self, bytes32 id, uint _counterSettlementValue) internal returns(bool){
        ClaimResponse memory cR;
        cR.counterSettlementValue = _counterSettlementValue;
        cR.claimID = id;
        cR.amountPaid = msg.value;
        cR.dateResponded = now;
        cR.accepted = false;
        self.responses[id].push(cR);

        return true;
    }
}
