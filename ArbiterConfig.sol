contract ArbiterConfig {

    uint internal _gracePeriod;
    uint public platformFee;
    uint public penaltyFee;
    address[] internal owners;

    function ArbiterConfig(address[] _owners){
        _gracePeriod = (3*86400);
        platformFee = (25*(1 ether)/100);
        penaltyFee = (1 ether);
        owners = owners;
    }

    function gracePeriod() constant returns(uint){
        return _gracePeriod;
    }

    function PenaltyFee(uint _dateIssued) constant returns(uint){
        return (now-(_dateIssued+gracePeriod()))/(86400) * penaltyFee;
    }

}
