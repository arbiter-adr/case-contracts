import "ArbiterConfig.sol";
import "CaseLibrary.sol";


contract Case {

    using CaseLibrary for CaseLibrary.Data;
    CaseLibrary.Data caseData;

    ArbiterConfig internal config;
    address public OriginatingParty;
    uint public dateIssued;



    event ClaimAcknowledged(bytes32 indexed claimID, address indexed acknowledgedBy, uint dateAcknowledged);
    event NewClaim();
    event ClaimResponse();
    event PenaltyIncurred;
    event AcknowledgeMessage;
    event DocumentSubmitted(string indexed documentHash, uint dateSubmitted);


    function Case(address _originatingParty, address[] _opposingParties, address _config){
        OriginatingParty = _originatingParty;
        dateIssued = now;
        config = ArbiterConfig(_config);

        caseData.originatingParties.primaryContract = _originatingParty;
        caseData.originatingParties.members.push(_originatingParty);
        caseData.originatingParties.isMember[_originatingParty] = true;

        caseData.opposingParties.primaryContract = _opposingParties[0];
        caseData.opposingParties.members = _opposingParties;
        for(var i = 0; i < _opposingParties.length; i++){
            caseData.opposingParties.isMember[_opposingParties[i]] = true;
        }
    }

    function addClaim(string _description, uint _desiredSettlementValue) public returns(bool){
        if(!caseData.newClaim(_description, _desiredSettlementValue)){
            return false;
        } else {
            return true;
        }
    }

    function getClaim(bytes32 _id) constant returns(string _description, uint _desiredSettlementValue,
        bytes32 _status, uint _dateIssued, uint _dateAmended, uint _dateDecided, uint _amountPaid){
        CaseLibrary.Claim memory c = caseData.claims[_id];
        return (c.description, c.desiredSettlementValue, c.status, c.dateIssued, c.dateAmended, c.dateDecided, c.amountPaid);
    }

    function initialAcknowledgement(bytes32 _id) isOpposingParty() public returns(bool){
        CaseLibrary.Claim memory c = caseData.claims[_id];
        if(now - c.dateIssued > config.gracePeriod()){
            caseData.penalties[_id][msg.sender] = config.PenaltyFee(c.dateIssued);
            caseData.claims[_id].acknowledged = true;
            return true;
        } else {
            caseData.claims[_id].acknowledged = true;
            return true;
        }

    }

    function claimResponse(bytes32 _id, uint _proposedSettlementValue) isOpposingParty() isNegotiable(_id) public returns(bool){
        if(!caseData.respondToClaim(_id, _proposedSettlementValue)){
            return false;
        } else {
            return true;
        }
    }

    function getClaims() constant returns(bytes32[]){
        return caseData.claimIDs;
    }

    function negotiateClaim(bytes32 _id, bool _decision) isOriginatingParty() isNegotiable(_id) public returns(bool){
        // Do we agree with the claim response from the opposing party?
        // if yes => close claim, update status;
        // if no => reject claimResponse and update claim if desired settlement value decreases;
        CaseLibrary.ClaimResponse memory CR = caseData.responses[_id][caseData.responses[_id].length - 1];
        CaseLibrary.Claim memory c = caseData.claims[_id];
        if(_decision){
            uint platformFee = CR.amountPaid*25/1000; //.25% platform fee; Place in a config Arbiter contract for later;
            if(!caseData.originatingParties.primaryContract.send(CR.amountPaid - platformFee)){
                throw;
            } else {


                // Update the Claim
                c.status = "resolved";
                c.dateDecided = now;
                c.amountPaid = CR.amountPaid;
                caseData.claims[_id] = c;

                // Update The Claim Response;
                CR.dateReceived = now;
                CR.accepted = true;
                caseData.responses[_id][caseData.responses[_id].length - 1] = CR;


                return true;
            }
        } else {
            CR.dateReceived = now;
            caseData.responses[_id][caseData.responses[_id].length - 1] = CR;
            return true;
        }

    }

    function getClaimResponse(bytes32 id) constant returns(bytes32 _claimID,
    uint _amountPaid, uint _counterSettlementValue, uint _dateResponded, bool _accepted){

        CaseLibrary.ClaimResponse memory CR;
        CR = caseData.responses[id][caseData.responses[id].length - 1];

        return (
            CR.claimID,
            CR.amountPaid,
            CR.counterSettlementValue,
            CR.dateResponded,
            CR.accepted
            );
    }

    modifier isOriginatingParty(){
        if(!caseData.originatingParties.isMember[msg.sender]){
            throw;
        } _
    }

    modifier isOpposingParty(){
        if(!caseData.opposingParties.isMember[msg.sender]){
            throw;
        } _
    }

    modifier isNegotiable(bytes32 id){
        if(caseData.claims[id].status == "verifying" || caseData.claims[id].status == "resolved" ){
            throw;
        } _
    }

}
