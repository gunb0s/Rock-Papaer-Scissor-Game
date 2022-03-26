import React, { useEffect, useState, createContext } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import Navigation from "./components/Navigation";
import GameRooms from "./components/GameRooms";
import styled from "styled-components";
import artifact from "./contracts/RPS.json";
import { isEmpty } from "lodash";
import { ethers } from "ethers";

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

const Context = createContext();
const Provider = Context.Provider;

const App = () => {
  const [account, setAccount] = useState("");
  const [web3, setWeb3] = useState({});
  const [rpsContract, setRpsContract] = useState(null);

  useEffect(() => {
    const { ethereum } = window;
    if (typeof ethereum !== "undefined") {
      console.log("MetaMask is installed!");
    }

    if (!isEmpty(web3)) {
      web3.getSigner(0).getAddress().then(setAccount);
      const rps = new ethers.Contract(
        artifact.contracts.RPS.address,
        artifact.contracts.RPS.abi,
        web3.getSigner()
      );
      setRpsContract(rps);
    }
  }, [web3]);

  return (
    <Container>
      <Provider value={{ setWeb3 }}>
        <Navigation account={account} />
        <Main>
          <GameRooms rps={rpsContract} />
        </Main>
      </Provider>
    </Container>
  );
};

export default App;
export { Context };
