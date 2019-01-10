pragma solidity ^0.4.23;
import './Ownable.sol';
import './CarToken.sol';

contract CarProposalModel is Ownable , CarToken {

   //检测签注结果
   enum ValueStatus{
       DEFAULT,
       PASS,
       NOTPASS
   }


   //合约运维方
   address public carTokenCore;
   CarToken internal carTokenBase;

    function () {
    //这个函数将会在发送到合约的交易事务包含无效数据
    //或无数据的时执行，这里撤销所有的发送，
    //所以没有人会在使用合约时因为意外而丢钱。
        throw;
    }


   //合约的构造方
   function CarProposalModel(
       address _owner,
       uint256 initialSupply,
       string tokenName,
       uint8 decimalUnits,
       string tokenSymbol) {
       require(_owner != address(0x0), "error: owner address is 0x00");
       carTokenCore = _owner;
       carTokenBase = CarToken(initialSupply,tokenName,decimalUnits,tokenSymbol);
   }

   //账号列表
   mapping (address =>Proposal[]) public offerInfo;
   mapping (address =>Proposal[]) public signInfo;
   mapping (address =>Proposal[]) public checkInfo;

  
   //提案
   struct Proposal {

       bytes32 filesign;
       string name;
       uint32 price;
       address[] checkPasser;
       address[] checkNotPasser;
       address signer ;
       bool isOpen;
       bool isCheck;
       bool isSigned;
       bool isValue;
   }

   event CreateProposal(
       address indexed _to,
       bytes32 indexed _filesign
   );

   event SetCarTokenCore(
       address  _from,
       address  _to
   );

   event Sent(
       address from, 
       address to, 
       uint amount
    );





    /* 
    * 逻辑合约修饰
    */
    modifier onlyCore() {
        require(msg.sender == carTokenCore, "Only Core contract modifier");
        _;
    }

    /*
    *设置合约运维方
    */
    function setCarTokenCore(address _carTokenCore) external onlyCore {
        SetCarTokenCore(carTokenCore,_carTokenCore);
        carTokenCore = _carTokenCore;
    }

    /*
    *创建提案
    */
   function createProposal(bytes32 _name,bytes32  _filesign,uint32 _price,bool _value) public {
       
       Proposal  p;
       p.name = _name;
       p.filesign = _filesign;
       p.price = _price;
       p.checkPassCount = 0;
       p.checkNotPassCount = 0;
       p.isOpen = true;
       p.isValue = _value;
       offerInfo[msg.sender()].push(p);
       CreateProposal(_to,_filesign); 
   }

    /*
    *查询自己地址有多少提案 msg.send()查询
    */
    function getValueOfferProposalLenght() public returns(uint) {
        return (offerInfo[msg.sender()]).length;
    }

    
    /*
    *查询自己地址有多少批准不过的提案 msg.send()查询
    */
    function getNoValueOfferProposalLenght() public returns(uint) {
        uint count = 0;
        for (int i = 0;i<(offerInfo[msg.sender()]).length;i++) {
            if ((offerInfo[msg.sender()])[i].isValue == true && (offerInfo[msg.sender()])[i].isCheck == false) {
                count++;
            }
        }
        return count;
    }

    /*
    *查询自己地址有多少没价值（正在审批中）的提案 msg.send()查询
    */
    function getNoValueOfferProposalLenght() public view returns(uint) {
        uint count = 0;
        for (int i = 0;i<(offerInfo[msg.sender()]).length;i++) {
            if ((offerInfo[msg.sender()])[i].isValue == false && (offerInfo[msg.sender()])[i].isCheck == true ) {
                count++;
            }
        }
        return count;
    }

    /*
    *查询自己地址有多少的提案 msg.send()查询
    */
    function getNoValueOfferProposalLenght() public view returns(uint) {
        uint count = 0;
        for (int i = 0;i<(offerInfo[msg.sender()]).length;i++) {
            if ((offerInfo[msg.sender()])[i].isValue == false && (offerInfo[msg.sender()])[i].isCheck == true ) {
                count++;
            }
        }
        return count;
    }


    /*
    *查询自己地址有多少签署的提案 msg.send()查询
    */
    function getMySignProposal() public view returns(Proposal[]) {
        return signInfo[msg.sender];
    }

    /*
    *查询自己地址有多少检测的提案 msg.send()查询
    */
    function getMyCheckerProposal() public view returns(Proposal[]) {
        return checkInfo[msg.sender];
    }


    /*
    *通过id查询地址的提案情况
    */
    function getProposalInfoByIdAndOwner(address _own,uint _id) public returns(Proposal) {
             return (offerInfo[_own])[_id];
    }

    /*
    *检测是否可以从NoValue状态改编为Value状态
    */
    function checkBeValue(Proposal p) internal returns(uint) {
         if ((p.checkNotPassCount+p.checkPassCount) >= 3) {
           if ((p.checkPassCount*2) > (p.checkNotPassCount+p.checkPassCount)) {
                 return ValueStatus.PASS;
           } else {
                return ValueStatus.NOTPASS;   
           }
       }
       return ValueStatus.DEFAULT;
    }


    /*
    *对无价值的提案进行批注sign 这个提交的请求
    */
    function signProposal(address _own,uint _id) public  returns(bool) {

        Proposal p = (offerInfo[_own])[_id];
        require(p.isOpen == true,"the Proposal is closed");
        if (p.isSigned == false && p.isValue == false) {
             (offerInfo[_own])[_id].signer = msg.sender();
             (offerInfo[_own])[_id].isSigned == true;
             signinfo[msg.sender()].push(p);
             return true;
        }
        return false;
    }

    
    /*
    *对已经批注sign的合约，进行检测
    */
   function checkProposalValue(address _owner,int32 _id,bool _isPass) public  returns (bool) {

       //一个地址智能进行标记一次
       //从offerinfo中获取       
       Proposal[]  parray = offerInfo[_owner];
       Proposal  p = parray[_id];

       require(p.isOpen == true,"the Proposal is closed");
       require(p.isCheck == false && p.isValue == false,"the Proposal is checked and it is  value");
       require(p.isSign == false,"the Proposal is  be signed");

       if (_isPass == false) {
           p.checkNotPassCount++;
       } else {
           p.checkPassCount++;
       }
       //审核人不是原始地址与签署地址
      
       checkInfo[msg.sender()].push(parray[_id]);
       //是否需要改变,触发条件

       uint f = checkBeValue(p);
       if (f == ValueStatus.DEFAULT) {
          
       }
       if (f == ValueStatus.NOPASS) {
            (offerInfo[_own])[_id].isCheck = true;
       }
       if (f == ValueStatus.PASS) {
            (offerInfo[_own])[_id].isValue = true;
            (offerInfo[_own])[_id].isCheck = true;
       }

       return true;
   }

   /*
   *用户主动 关闭一个合约
   */
   function closeProposal(uint _id) public  returns(bool) {
   
        Proposal p = (offerInfo[msg.sender])[_id];
        require(p.isOpen == true,"the Proposal is closed");
        p.isOpen = false;
        return true;
   }

//     /*
//    *开启合约，关闭一个合约之后，开启只能是官方开启
//    */
//    function openProposalByCore(address _own,uint _id) public  onlyCore returns(bool) {
//         require((offerInfo[_own])[_id].isOpen == false,"the Proposal is open");
//         (offerInfo[_own])[_id].isOpen = true;
//         return true;
//    }

    /*
   *官方关闭一个合约
   */
   function closeProposalByCore(address _own,uint _id) public  onlyCore returns(bool) {
        require((offerInfo[_own])[_id].isOpen == true,"the Proposal is already close");
        (offerInfo[_own])[_id].isOpen = false;
        return true;
   }

   /*
   *开始购买
   */
   function buyProposal(address _owner,uint _id) public  returns (bool) {
            Proposal p = (offerInfo[_owner])[_id];
            require(p.isOpen == true,"the proposal is close");
            require(p.isValue == true,"the proposal is no value");
            require(p.price<=msg.value,"not enough money");

            uint psum = 0;
            uint paySigner = p.price*0.1;
            
            
            transfer(p.signer, paySigner);
            psum += paySigner;

            uint payPaseChecker = p.price*0.03;

            for (int i = 0;i<p.checkPasser.length;i++) {
                carTokenBase.transfer(p.checkPasser[i], pay);
                psum += payPaseChecker;
            }

            uint payNoPaseChecker = p.price*0.04;
            for (int i = 0;i<p.checkNoPasser.length;i++) {
                carTokenBase.transfer(p.checkNoPasser[i], pay);
                psum += payNoPaseChecker;
            }
            
            uint _value = p.price - psum;
            carTokenBase.transfer(_own, _value);
            
            return true; 
        }

}