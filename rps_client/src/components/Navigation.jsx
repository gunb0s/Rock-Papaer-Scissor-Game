import React from "react";
import { Navbar, Container, Nav } from "react-bootstrap";

const Navigation = ({ account, handleAccount }) => {
  return (
    <Navbar bg="dark" variant="dark">
      <Container>
        <Navbar.Brand href="#home">Rock-Paper-Scissor Game</Navbar.Brand>
        <Nav className="me-auto">
          <Nav.Link href="#home">Home</Nav.Link>
          {account === "" ? (
            <Nav.Link
              onClick={async () => {
                const accounts = await window.ethereum.request({
                  method: "eth_requestAccounts",
                });
                handleAccount(accounts[0]);
              }}
            >
              Enable Ethereum
            </Nav.Link>
          ) : (
            <Nav.Link>{account}</Nav.Link>
          )}
        </Nav>
      </Container>
    </Navbar>
  );
};

export default Navigation;
