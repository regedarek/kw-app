import React from 'react';
import ReactDOM from 'react-dom';
import EventsCalendarContainer from "../src/eventsCalendarContainer";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <EventsCalendarContainer />,
      document.getElementById("events_component"),
    )
  })
  