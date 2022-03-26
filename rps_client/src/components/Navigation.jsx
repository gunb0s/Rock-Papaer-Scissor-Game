import React, { useContext } from "react";
import { ethers } from "ethers";
import { Navbar, Container, Nav } from "react-bootstrap";
import { Context } from "../App";

const Navigation = ({ account }) => {
  const context = useContext(Context);
  const registerWeb3 = async () => {
    // const accounts = await window.ethereum.request({
    //   method: "eth_requestAccounts",
    // });
    context.setWeb3(new ethers.providers.Web3Provider(window.ethereum));
  };

  return (
    <Navbar bg="dark" variant="dark">
      <Container>
        <Navbar.Brand href="#home">Rock-Paper-Scissor Game</Navbar.Brand>
        <Nav className="me-auto">
          <Nav.Link href="#home">Home</Nav.Link>
          {account === "" ? (
            <Nav.Link onClick={registerWeb3}>Enable Ethereum</Nav.Link>
          ) : (
            <Nav.Link>{account}</Nav.Link>
          )}
        </Nav>
      </Container>
    </Navbar>
  );
};

export default Navigation;
