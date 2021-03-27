import React from 'react';
import 'whatwg-fetch';
import Spinner from "../spinner";
import StravaList from "./stravaListComponent";
import { ToastContainer, toast } from 'react-toastify';

class StravaListContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isLoading: false,
      data: []
    };
  }
  
  componentDidMount() {
    this.setState({
      isLoading: true,
    })
    window.fetch(`/activities/api/strava_activities?user_id=${this.props.userId}`)
      .then(response => response.json())
      .then(data => {
        console.log(data)
        this.setState({
          data,
          isLoading: false
        });
      });
  }

  onImport(id) {
    window.fetch('/activities/api/strava_activities', {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_id: this.props.userId,
        strava_id: id
      })
    })
    .then(response => response.json())
    .then(data => {
      toast.success(<span>Zaimportowana aktywność, <a href={`/przejscia/${data.id}`}>Link</a></span>, {
        position: toast.POSITION.BOTTOM_RIGHT
      });
    })
  }

  render() {
    if (this.state.isLoading) {
      return <Spinner></Spinner>
    }
    return <>
        <ToastContainer />
        {this.state.isLoading && 
          <div className="row">
            <div className="columns large-12 text-center">
              <Spinner></Spinner>
            </div>
          </div>
        }
        {!this.state.isLoading && <StravaList items={this.state.data} onImport={this.onImport.bind(this)} /> }
      </>
  }
}

export default StravaListContainer;
