import React from 'react';
import ReactDOM from 'react-dom';
import EventsCalendarContainer from "./eventsCalendarContainer";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <EventsCalendarContainer />,
      document.getElementById("events_component"),
    )
  })
  