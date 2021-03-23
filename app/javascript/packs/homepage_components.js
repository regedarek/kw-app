import React from 'react';
import ReactDOM from 'react-dom';
import EventsCalendarContainer from "../src/eventsCalendarContainer";
import FileUploader from "../src/fileUploader";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <EventsCalendarContainer />,
      document.getElementById("events_component"),
    )
  })
  