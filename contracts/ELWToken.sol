pragma solidity ^0.4.24;

//import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";


/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
   * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
**/
contract ELWToken is MintableToken {

  string public constant name = "ElysiaWon";
  string public constant symbol = "ELW";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 1e4 * (10 ** uint256(decimals));

  // bytes32 : 32 letters (ASCII): each character is a byte.
  mapping (address => mapping (bytes32 => uint256)) internal buildingToken;

  struct Tokens {
    bytes32 name;
    uint256 value;
  }

  mapping (uint256 => Tokens) internal tokens;
  uint256[] public tokensIndex;

  // name : Name of token
  event TransferToken(address indexed from, address indexed to, bytes32 name, uint256 value, uint256 price);

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    //_mint(msg.sender, INITIAL_SUPPLY);
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY); // ERC20Basic.sol
  }

  function createELW(
    uint256 _value
  )
    onlyOwner
    public
    returns (bool)
  {
    require(_value >= 0);

    balances[owner] = balances[owner].add(_value);
    emit Transfer(0x0, msg.sender, _value);
    return true;
  }

  function burnELW(
    uint256 _value
  )
    onlyOwner
    public
    returns (bool)
  {
    require(_value >= 0);
    require(_value <= balances[owner]);

    balances[owner] = balances[owner].sub(_value);
    emit Transfer(msg.sender, 0x0, _value);
    return true;
  }

  function transferOwner(
    address _from,
    address _to,
    uint256 _value
  )
    onlyOwner
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_from != address(0));
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

    // When Token tranfer, owner take the permission of Token
    if(allowed[_to][_from] == 0) {
      allowed[_to][_from] = _value;
    } else {
      allowed[_to][_from] += _value;
    }
    emit Transfer(_from, _to, _value);
    return true;
  }


  function createToken(
    bytes32 _name,
    uint256 _value
  )
    onlyOwner
    public
    returns (bool)
  {
    buildingToken[msg.sender][_name] = _value;
    tokens[tokensIndex.length].name = _name;
    tokens[tokensIndex.length].value = _value;
    tokensIndex.push(tokensIndex.length);
    emit TransferToken(0x0, msg.sender, _name, _value, 0);
    return true;
  }

  function burnToken(
    bytes32 _name,
    uint256 _value
  )
    onlyOwner
    public
    returns (bool)
  {
    require(_value >= 0);
    require(_value <= buildingToken[owner][_name]);

    buildingToken[owner][_name] = buildingToken[owner][_name].sub(_value);
    emit TransferToken(msg.sender, 0x0, _name, _value, 0);
    return true;
  }

  function getTokenName(uint256 _index) onlyOwner public view returns (bytes32) {
    return tokens[_index].name;
  }

  function getTokenAmount(uint256 _index) onlyOwner public view returns (uint256) {
    return tokens[_index].value;
  }

  function getTokenCount() onlyOwner public view returns (uint256) {
    return tokensIndex.length;
  }

  // TODO : "Exchange" will be divided "buy" and "sell"
  function exchangeELToken(
    address _from,
    address _to,
    bytes32 _name,     // Token name
    uint256 _value,    // Token amount
    uint256 _price     // Token price(EL or ELW)
  )
    onlyOwner
    public
    returns (bool)
  {
    require(_from != address(0));
    require(_to != address(0));
    require(_from == owner || _to == owner);  // Only the owner and the user can exchange it.
    require(_price <= balances[_to]);
    require(_value <= buildingToken[_from][_name]);

    // EL(_price) : to -> from
    balances[_to] = balances[_to].sub(_price);
    balances[_from] = balances[_from].add(_price);

    // Permission of user
    if(_to != owner) {
      allowed[_to][owner] = allowed[_to][owner].sub(_price);
    }

    // buildingToken(_value) : from -> to
    buildingToken[_from][_name] = buildingToken[_from][_name].sub(_value);
    buildingToken[_to][_name] = buildingToken[_to][_name].add(_value);

    emit TransferToken(_from, _to, _name, _value, _price);
    return true;
  }

  // Get user's buildingToken
  function buildingTokenOf(
    address _who,
    bytes32 _name
  )
    public
    view
    returns (uint256)
  {
    return buildingToken[_who][_name];
  }

  // TEST COIN
  /**
  function getInfoOfToken() public view returns (string, string, uint256) {
    return (name, symbol, INITIAL_SUPPLY);
  }

  function getInfoOfUser(address _from, address _to) public view returns (uint256, uint256) {
    return (balances[_from], allowed[_from][_to]);
  }

  function stringToBytes32(string memory _source) returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(_source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(_source, 32))
    }
  }
  **/
}
