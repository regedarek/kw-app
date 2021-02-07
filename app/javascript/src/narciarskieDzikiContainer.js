import React from 'react';
import 'whatwg-fetch';

import NarciarskieDziki from "./narciarskieDziki";

class NarciarskieDzikiComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: []
    };
  }
  
  componentDidMount() {
    window.fetch('/api/routes/2021/season')
      .then(response => response.json())
      .then(data => {
        this.setState({
          data
        });
      });
  }

  render() {
    return <NarciarskieDziki data={this.state.data} />;
  }
}

export default NarciarskieDzikiComponent;
