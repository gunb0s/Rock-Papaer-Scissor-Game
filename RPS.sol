//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {
    // enum Hand {
    //     rock, paper, scissors
    // }
    enum PlayerStatus {
        STATUS_WIN, STATUS_LOSE, STATUS_TIE, STATUS_PENDING
    }
    struct Player {
        address payable addr;
        uint256 playerBetAmount;
        uint8 hand;
        PlayerStatus playerStatus;
    }
    enum GameStatus {
        STATUS_NOT_STARTED, STATUS_STARTED, STATUS_COMPLETE, STATUS_ERROR
    }
    struct Game {
        Player originator;
        Player taker;
        uint256 betAmount;
        GameStatus gameStatus;
    }

    mapping(uint => Game) rooms;
    uint roomLen = 0;

    constructor() payable {}

    // modifier isValidHand(Hand _hand) {
    //     require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors));
    //     _;
    // }

    // // sender의 타입은 address, originator와 taker의 type은 address payable이다
    // modifier isPlayer(uint roomNum, address sender) {
    //     require(payable(sender) == rooms[roomNum].originator.addr || payable(sender) == rooms[roomNum].taker.addr);
    //     _;
    // }
    function createRoom(bytes memory _hand) public payable returns (uint roomNum) {
        uint8 result = verify(msg.sender, _hand);
        require(result != 3);

        rooms[roomLen] = Game({
            betAmount: msg.value,
            gameStatus: GameStatus.STATUS_NOT_STARTED,
            originator: Player({
                hand: result,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value
            }),
            taker: Player({
                hand: 0,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: 0
            })
        });
        roomNum = roomLen;
        roomLen = roomLen + 1;
    }

    function joinRoom(uint roomNum, bytes memory _hand) public payable {
        require(rooms[roomNum].gameStatus != GameStatus.STATUS_COMPLETE || rooms[roomNum].gameStatus != GameStatus.STATUS_ERROR);
        uint8 result = verify(msg.sender, _hand);
        require(result != 3);

        rooms[roomNum].taker = Player({
            hand: result,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value
        });
        rooms[roomNum].betAmount = rooms[roomNum].betAmount + msg.value;
        
        compareHands(roomNum);
        payout(roomNum);
    }

    function compareHands(uint roomNum) private {
        uint originator = uint8(rooms[roomNum].originator.hand);
        uint taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].gameStatus = GameStatus.STATUS_STARTED;

        if (taker == originator) {
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_TIE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_TIE;
        } else if ((taker + 1) % 3 == originator) {
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_WIN;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_LOSE;
        } else if ((originator + 1) % 3 == taker) {
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_LOSE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_WIN;
        } else {
            rooms[roomNum].gameStatus = GameStatus.STATUS_ERROR;
        }
    }

    /**
     * payout함수를 실행하는 주체는 방장또는 참가자여야 한다 참가자는 중간에 자신이 낸 값을 변경할 수도 있기 때문이다????
     * payout은 방에 참가자가 참가해서 가위바위보가 실행되면 자동으로 실행되며 외부에서 따로 실행할 필요는 없을 거 같다
     */
    function payout(uint roomNum) private {
        if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_TIE && rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_TIE) {
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
        } else {
            if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_WIN) {
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].betAmount);
            } else if (rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_WIN) {
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].betAmount);
            } else {
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
            }
        }

        rooms[roomNum].gameStatus = GameStatus.STATUS_COMPLETE;
    }

    function verify(address _sender, bytes memory _sig) public pure returns (uint8) {
        bytes32 message_rock = ethMessageHash("rock");
        bytes32 message_paper = ethMessageHash("paper");
        bytes32 message_scissor = ethMessageHash("scissor");
        
        if (recover(message_rock, _sig) == _sender) {
            return 0;
        } else if (recover(message_paper, _sig) == _sender) {
            return 1;
        } else if (recover(message_scissor, _sig) == _sender) {
            return 2;
        } else {
            return 3;
        }
    }

    function recover(bytes32 _hash, bytes memory _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_sig.length != 65) {
            return address(0);
        }

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }

    function ethMessageHash(string memory _message) internal pure returns (bytes32) {
         return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _message)
            );
    }
}