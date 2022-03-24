import React, { useEffect, useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import Navigation from "./components/Navigation";
import GameRooms from "./components/GameRooms";
import styled from "styled-components";
import Web3 from "web3";
import artifact from "./contracts/RPS.json";

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
  const web3 = new Web3(
    "https://eth-rinkeby.alchemyapi.io/v2/5Evj6P8gVOWygwsWXfAHVjarFvrGhH3v"
  );

  const [account, setAccount] = useState("");
  const [rpsContract, setRpsContract] = useState(null);

  useEffect(() => {
    const { ethereum } = window;
    if (typeof ethereum !== "undefined") {
      console.log("MetaMask is installed!");

      const rps = new web3.eth.Contract(
        artifact.contracts.RPS.abi,
        artifact.contracts.RPS.address,
        { from: account }
      );
      setRpsContract(rps);
    }
  }, [account]);

  return (
    <Container>
      <Navigation account={account} handleAccount={setAccount} />
      <Main>
        <GameRooms rps={rpsContract} />
      </Main>
    </Container>
  );
};

export default App;
