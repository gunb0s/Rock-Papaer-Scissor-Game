import React from "react";
import { ListGroup } from "react-bootstrap";

const GameRoom = ({ rooms }) => {
  const game = (status) => {
    if (status === "0") {
      return "Ready";
    } else if (status === "1") {
      return "Started";
    } else if (status === "2") {
      return "Complete";
    } else {
      return "Error";
    }
  };

  return (
    <>
      {Object.keys(rooms).map((room, idx) => {
        const { roomNumber, originator, taker, betAmount, gameStatus } =
          rooms[room];
        return (
          <ListGroup.Item key={idx}>
            <h3>{roomNumber}</h3>
            <span>{game(gameStatus)}</span>
          </ListGroup.Item>
        );
      })}
    </>
  );
};

export default GameRoom;
