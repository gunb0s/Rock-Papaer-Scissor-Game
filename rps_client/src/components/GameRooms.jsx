import React, { useState, useEffect } from "react";
import { ListGroup } from "react-bootstrap";
import GameRoom from "./GameRoom";

const GameRooms = ({ rps }) => {
  const [rooms, setRooms] = useState({});
  // To get all element of mapping rooms easily, I should have implemented size funtcion of rooms
  const getRooms = async () => {
    if (rps === null) return;
    let i = 0;
    while (true) {
      const room = await rps.methods.rooms(i).call();
      // console.log(i, room);
      if (room[0][0] !== "0x0000000000000000000000000000000000000000") {
        setRooms((prev) => {
          return {
            ...prev,
            [i]: {
              roomNumber: i,
              originator: room["originator"]["addr"],
              taker: room["taker"]["addr"],
              betAmount: room["betAmount"],
              gameStatus: room["gameStatus"],
            },
          };
        });

        i++;
      } else {
        break;
      }
    }
  };

  useEffect(() => {
    getRooms();
  }, [getRooms]);

  return (
    <ListGroup variant="flush">
      <GameRoom rooms={rooms} />
    </ListGroup>
  );
};

export default GameRooms;
