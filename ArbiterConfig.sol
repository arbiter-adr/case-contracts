contract ArbiterConfig {

    uint internal gracePeriod;
    uint public platformFee;
    uint public penaltyFee;
    address[] internal owners;

    function ArbiterConfig(address[] _owners){
        gracePeriod = (3*86400);
        platformFee = (25*(1 ether)/100);
        penaltyFee = (1 ether);
        owners = owners;
    }

    function GracePeriod() constant returns(uint){
        return gracePeriod;
    }

    function PenaltyFee(uint _dateIssued) constant returns(uint){
        return (now-(_dateIssued+GracePeriod()))/(86400) * penaltyFee;
    }

}
