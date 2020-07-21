import React from 'react';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Card from 'react-bootstrap/Card';
import 'bootstrap/dist/css/bootstrap.min.css';

function ResultItem() {
  return (
      <Row>
          <Col>
              <Card>
                  <Card.Body>This is some text within a card body.</Card.Body>
              </Card>
          </Col>
      </Row>
  );
};

export default ResultItem;
