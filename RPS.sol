//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {
    enum Hand {
        rock, paper, scissors
    }
    enum PlayerStatus {
        STATUS_WIN, STATUS_LOSE, STATUS_TIE, STATUS_PENDING
    }
    struct Player {
        address payable addr;
        uint256 playerBetAmount;
        Hand hand;
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

    modifier isValidHand(Hand _hand) {
        require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors));
        _;
    }

    // sender의 타입은 address, originator와 taker의 type은 address payable이다
    modifier isPlayer(uint roomNum, address sender) {
        require(sender == rooms[roomNum].originator.addr || sender == rooms[roomNum].taker.addr);
        _;
    }

    function createRoom(Hand _hand) public payable isValidHand(_hand) returns (uint roomNum) {
        rooms[roomLen] = Game({
            betAmount: msg.value,
            gameStatus: GameStatus.STATUS_NOT_STARTED,
            originator: Player({
                hand: _hand,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value
            }),
            taker: Player({
                hand: Hand.rock,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: 0
            })
        });
        roomNum = roomLen;
        roomLen = roomLen + 1;
    }

    function joinRoom(uint roomNum, Hand _hand) public payable isValidHand(_hand) {
        rooms[roomNum].taker = Player({
            hand: _hand,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value
        });
        rooms[roomNum].betAmount = rooms[roomNum].betAmount + msg.value;
        compareHands(roomNum);
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
     * payout함수를 실행하는 주체는 방장또는 참가자여야 한다 참가자는 중가에 자신이 낸 값을 변경할 수도 있기 때문이다????
     */
    function payout(uint roomNum) public payable isPlayer(roomNum, msg.sender) {
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
}