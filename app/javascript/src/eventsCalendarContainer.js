import React from 'react';
import 'whatwg-fetch';

import EventsCalendar from "./eventsCalendar";

class EventsCalendarContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: []
    };
  }
  
  componentDidMount() {
    window.fetch('/supplementary/api/courses?order=start_date')
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
