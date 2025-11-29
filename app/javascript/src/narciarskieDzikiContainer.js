import React from 'react';
import 'whatwg-fetch';

import NarciarskieDziki from "./narciarskieDziki";
import NarciarskieDzikiSmall from "./narciarskieDzikiSmall";
import Spinner from "./spinner";

function compareWith(comparisionType) {
  return function (a, b) {
    if (!a) {
        return 1;
    }
    if (!b) {
        return -1;
    }

    return b[comparisionType] - a[comparisionType]
  }
}

const sortByMap = {
  "winter": "total_mountain_routes_length",
  "spring": "total_mountain_routes_length",
  "season": "total_length"
}

class NarciarskieDzikiComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: [],
      isLoading: true
    };
  }
  
  componentDidMount() {
    const route = '/api/routes/2025/' + this.props.type + (this.props.gender ? `?gender=${this.props.gender}` : "");
    window.fetch(route)
      .then(response => response.json())
      .then(data => {
        this.setState({
          data: this.sanitizeData(data),
          isLoading: false
        });
      });
  }

  sanitizeData(data) {
    const sortedData = (data || []).sort(compareWith(sortByMap[this.props.type]));
    return sortedData.map((dzik) => {
      const displayObj = {
          avatar: "",
          displayName: "",
          trainingContractsLength: 0,
          totalMountainRoutesLength: 0,
          totalLength: 0,
          last_activity: {},
          kwId: null
      }
      if (dzik && dzik.leader) {
          displayObj.avatar = dzik.leader.avatar && dzik.leader.avatar.url;
          displayObj.displayName = dzik.leader.display_name;
          displayObj.kwId = dzik.leader.kw_id;
      }
      if (dzik) {
          displayObj.trainingContractsLength = dzik.training_contracts_length;
          displayObj.totalMountainRoutesLength = dzik.total_mountain_routes_length;
          displayObj.totalLength = dzik.total_length;
          displayObj.last_activity = dzik.last_activity;
      }

      return displayObj;
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
    
    if (this.props.isSmall) {
      return (<NarciarskieDzikiSmall data={this.state.data} keyPrefix={"" + Math.random()} />);
    }
    return (<NarciarskieDziki data={this.state.data} keyPrefix={"" + Math.random()} />);
  }
}

export default NarciarskieDzikiComponent;
