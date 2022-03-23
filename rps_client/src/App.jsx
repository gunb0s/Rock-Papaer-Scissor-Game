import React, { useEffect } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import Navigation from "./components/Navigation";
import GameRooms from "./components/GameRooms";
import styled from "styled-components";

const Container = styled.div`
  height: 100vh;
`;

const Main = styled.main`
  width: 100%;
  height: 100%;
  display: flex;
  padding-left: 5rem;
  padding-top: 2rem;
  padding-bottom: 2rem;
`;

const App = () => {
  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      console.log("MetaMask is installed!");
    }
  });

  return (
    <Container>
      <Navigation />
      <Main>
        <GameRooms />
      </Main>
    </Container>
  );
};

export default App;
