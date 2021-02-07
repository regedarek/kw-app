import React from 'react';
import 'whatwg-fetch';

import NarciarskieDziki from "./narciarskieDziki";
import NarciarskieDzikiSmall from "./narciarskieDzikiSmall";
import Spinner from "./spinner";

function compareTotals(a, b) {
  if (!a) {
      return 1;
  }
  if (!b) {
      return -1;
  }

  return b.total_length - a.total_length;
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
    window.fetch('/api/routes/2021/' + this.props.type)
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
    const sortedData = (this.state.data || []).sort(compareTotals);
    const sanitizedData = sortedData.map((dzik, id) => {
      const displayObj = {
          avatar: "",
          displayName: "",
          trainingContractsLength: 0,
          totalMountainRoutesLength: 0,
          totalLength: 0,
          last_activity: {},
      }
      if (dzik && dzik.leader) {
          displayObj.avatar = dzik.leader.avatar && dzik.leader.avatar.url;
          displayObj.displayName = dzik.leader.display_name;
      }
      if (dzik) {
          displayObj.trainingContractsLength = dzik.training_contracts_length;
          displayObj.totalMountainRoutesLength = dzik.total_mountain_routes_length;
          displayObj.totalLength = dzik.total_length;
          displayObj.last_activity = dzik.last_activity;
      }

      return displayObj;
    });
    if (this.props.isSmall) {
      return (<NarciarskieDzikiSmall data={sanitizedData} keyPrefix={"" + Math.random()} />);
    }
    return (<NarciarskieDziki data={sanitizedData} keyPrefix={"" + Math.random()} />);
  }
}

export default NarciarskieDzikiComponent;
