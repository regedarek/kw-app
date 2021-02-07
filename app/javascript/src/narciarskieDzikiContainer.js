import React from 'react';
import 'whatwg-fetch';

import NarciarskieDziki from "./narciarskieDziki";
import Spinner from "./spinner";

class NarciarskieDzikiComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: [],
      isLoading: true
    };
  }
  
  componentDidMount() {
    window.fetch('/api/routes/2021/season')
      .then(response => response.json())
      .then(data => {
        this.setState({
          data,
          isLoading: false
        });
      });
  }

  render() {
    if (this.state.isLoading) {
        return (<div style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center"
        }}>
            <Spinner /> 
        </div>);
    }
    return <NarciarskieDziki data={this.state.data} />;
  }
}

export default NarciarskieDzikiComponent;
