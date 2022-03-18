# RPS contract를 dApp화하기위한 방법

## Issue

    1. 방장이 createRoom tx를 만들면 이것을 모두가 확인이 가능하며 이에 따라 참가자가 값을 내면 베팅한 돈을 가져갈 수 있다
    2. compareHands에서 결과가 나오면 바로 payout이 진행되어야 한다
    3. payout함수는 아무나 호출하면 안된다, 그 방에 참여한 사람들에 의해 호출되어야 한다
    4. 방이 오래동안 STATUS_NOT_STARTED상태일 때의 처리가 필요할 것 같다
    5. 제공된 코드에서 isPlayer의 sender는 address type인데, originator와 taker의 type은 address payable이다
