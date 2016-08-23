/*
Inheritance/Dependency of Contracts;

Arbiter (have some top level contract that contains all cases);



Cases
Case is Cases (one or more claims) => when a new claim is issued, the case is created;
Claim is Case;


*/
import "ArbiterConfig.sol";
import "Case.sol";

contract Cases {

    ArbiterConfig internal config;

    function Cases(address _config){
      config = ArbiterConfig(_config);
    }

    event NewCase(address indexed _originatingParty, address[] indexed _opposingParty, address indexed _case);

    address[] public cases;

    function newCase(address[] _opposingParties) public returns(bool){
        Case c = new Case(msg.sender, _opposingParties, config);
        cases.push(c);
        NewCase(msg.sender, _opposingParties, c);
        return true;
    }

    function getCases() constant returns(address[]){
        return cases;
    }
}
