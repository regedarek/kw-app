import React from 'react';

import EventsCalendar from "./eventsCalendar";

class EventsCalendarContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: []
    };
  }
  
  componentDidMount() {
    fetch('/supplementary/api/courses?order=id')
      .then(response => response.json())
      .then(data => {
        this.setState({
          data
        });
      });
  }

  render() {
    return <EventsCalendar events={this.state.data} />;
  }
}

export default EventsCalendarContainer;