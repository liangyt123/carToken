pragma solidity ^0.4.24;
import './CarToken.sol';

contract CarTokenOp is CarToken {
    
    //创建car
   //CarToken initCar =  CarTonken(1000,"asd",23210,"sd");
   //3种用户
    //提案
   struct proposal {

       bytes32 filesign;
       bytes32 name;
       //跟踪
       uint32 price;
       //uint32 offerIndex;
       uint32 checkPassCount;
       uint32 checkNotPassCount;

       bool isOpen;
       bool isValue;
       bool isCheck;
       //uint32 checkerIndex;  
   } 
   
   mapping (address =>proposal[]) public offerInfo;
   mapping (address =>proposal[]) public signInfo;
   mapping (address =>proposal[]) public checkInfo;

   event CreateProposal(address indexed _to,bytes32 indexed _filesign);

   function createValueproposal(bytes32 _name,bytes32  _filesign,uint32 _price) public {
       
       proposal  p;
       p.name = _name;
       p.filesign = _filesign;
       p.price = _price;
       p.checkPassCount = 0;
       p.checkNotPassCount = 0;
       p.isOpen = true;
       p.isValue = true;
       len = offerInfo[msg.sender()].length;
       p.offerIndex = len;
       offerInfo[msg.sender()].push(p);
       CreateProposal(_to,_filesign); 

   }

   function createNovalueproposal(bytes32 _name,bytes32  _filesign,uint32 _price) public {
       
       poprosal  p;
       p.name = _name;
       p.filesign = _filesign;
       p.price = _price;
       p.checkPassCount = 0;
       p.checkNotPassCount = 0;
       p.isOpen = true;
       p.isValue = false;
       //查看是否已经有了
       len = offerInfo[msg.sender()].length;
       p.offerIndex = len;
       offerInfo[msg.sender()].push(p);
       CreateProposal(_to,_filesign);

   }

   function changeNovalueToValue(address indexed _from,uint32 _offerIndex) public {

       p = offerInfo[_from];
       p[offerIndex].isValue == true;

   }

    function signProposal(address indexed _from,bytes _offerIndex) public {
       p = offerInfo[_from];
       p[offerIndex].isSign = true;    
    }



   function showNovalueproposal() {

   }

   function showValueproposal() {

    }

    function signNoValueproposal() {
        
    }

   //Minning
   function transferAndMinning(address _to,address _from, uint _value) public {
       
       transfer(from, to, value);
       //_value = 9999
       //balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);

   }


}