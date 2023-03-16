pragma solidity ^0.7.5;
pragma abicoder v2;

contract multiSig {
    address[] public owners;
    uint limit;

    constructor (address[] memory _owners, uint _limit){
        owners = _owners;
        limit = _limit;
    }

    modifier onlyOwners(){
        bool owner =  false;
        for (uint index = 0; index < owners.length; index++) {
            if(owners[index] == msg.sender){
                owner = true;
            }
        }
        require(owner == true);
        _;
    }


    // functions
    function deposit() public payable {

    }   


    struct Transfer {
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }


    //events is used to notification in solidity
    // create all events
    event transferRequestCreated(uint _id, uint _amount, address _initiator, address _receiver );
    event approvalReceived(uint _id, uint _approvals, address _approver);
    event transferApproved(uint _id);
    // then call using emit keyword where the event call


    Transfer[] transferRequest;

    function createTransfer(uint _amount , address payable _receiver) public onlyOwners{

        // here emit is caleed to notification
        emit transferRequestCreated(transferRequest.length, _amount, msg.sender, _receiver);
        transferRequest.push(Transfer(_amount, _receiver, 0, false, transferRequest.length));
    }

    // Double mapping
    mapping (address => mapping(uint => bool)) approvals;


    function approve(uint _id) public onlyOwners{
        require(transferRequest[_id].hasBeenSent == false);

        //its double mapping calling
        require(approvals[msg.sender][_id] == false , "you already voted!");

        approvals[msg.sender][_id] == true ;
        transferRequest[_id].approvals++ ;

        // here another notification
        emit approvalReceived(_id, transferRequest[_id].approvals, msg.sender);


        if(transferRequest[_id].approvals >= limit){
            
            transferRequest[_id].receiver.transfer(transferRequest[_id].amount);
            transferRequest[_id].hasBeenSent == true;
            emit transferApproved(_id);
        }

    }

    // returns kay argument ma struct ek error dta ha jo line no 2 par solve kia h
    function getTransactionRequest()public view returns (Transfer[] memory){
        return transferRequest;
    }

    function getBalance()public view returns(uint){
        return address(this).balance;
    }
     
}