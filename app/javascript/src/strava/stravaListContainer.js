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
      allSelected: false,
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
      toast.success(<span>Zaimportowane aktywności, <a href={`/przejscia#my_strava_routes`}>Link</a></span>, {
        position: toast.POSITION.BOTTOM_RIGHT
      });

      this.setState({
        data: this.state.data.filter(el => id !== el.id)
      })
    })
  }

  onSelect(id) {
    this.setState({
      data: this.state.data.map(el => ({
        ...el,
        ...(el.id === id && {checked: !el.checked} )
      }))
    })
  }

  onSelectAll() {
    this.setState({
      allSelected: !this.state.allSelected,
      data: this.state.data.map(el => ({
        ...el,
        checked: !this.state.allSelected
      }))
    })
  }

  onImportSelected() {
    this.state.data.filter(el => el.checked).forEach(el => {
      this.onImport(el.id)
    })
  }

  getSelectCount() {
    return (this.state.data || []).filter(el => el.checked).length
  }

  render() {
    return <>
        <ToastContainer />
        { this.state.isLoading && 
          <div className="row">
            <div className="columns large-12 text-center">
              <Spinner centered={true}></Spinner>
            </div>
          </div>
        }
        {!this.state.isLoading && <StravaList items={this.state.data} onImport={this.onImport.bind(this)}
          onImportSelected={this.onImportSelected.bind(this)} onSelect={this.onSelect.bind(this)} onSelectAll={this.onSelectAll.bind(this)}
          allSelected={this.state.allSelected}
          selectCount={this.getSelectCount()}
        /> }
      </>
  }
}

export default StravaListContainer;
