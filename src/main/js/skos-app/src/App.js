import React from 'react';
import Navbar from 'react-bootstrap/Navbar';
import Nav from 'react-bootstrap/Nav';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import {
    BrowserRouter as Router,
    Switch,
    Route
} from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';
import ResultItem from './ResultItem';
import FacetItem from './FacetItem';

const a = [1, 10, 100];
const b = [1, 10, 100, 1000, 10000, 4];

function App() {
    return (
        <Router>
        <Navbar bg="dark" variant="dark" fixed="top">
        <Navbar.Brand href="/"><img alt="" src="https://avatars3.githubusercontent.com/u/2393489?s=200&v=4" weign="40" height="40"/> My React Application</Navbar.Brand>
    <Nav className="mr-auto">
        <Nav.Link href="/">Home</Nav.Link>
        <Nav.Link href="/features">Features</Nav.Link>
        <Nav.Link href="/pricing">Pricing</Nav.Link>
        </Nav>
        </Navbar>
        <div className="full">
        <Switch>
        <Route path="/features">
            <h1>Features</h1>
        </Route>
        <Route path="/pricing">
            <h1>Pricing</h1>
        </Route>
        <Route path="/">
            <Container style={{width: "100%", margin: 0, padding: 0}} fluid>
                <Row>
                    <Col md={2} style={{margin: 0, padding: 0}}>
                        <Container style={{width: "100%", margin: 0, padding: 0}}>
                            {a.map(i => {
                                return (
                                    <FacetItem item={i} />
                                )
                            })}
                        </Container>
                    </Col>
                    <Col style={{margin: 0, padding: 0}}>
                        <Container style={{width: "100%", margin: 0, padding: 0}} fluid>
                            {b.map(i => {
                                return (
                                    <ResultItem item={i} />
                                )
                            })}
                        </Container>
                    </Col>
                </Row>
            </Container>
        </Route>
        </Switch>
        </div>
        </Router>
);
}

export default App;
