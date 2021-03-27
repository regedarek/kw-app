import React from 'react';
import ReactDOM from 'react-dom';

import StravaList from "../src/strava"; 

document.addEventListener('DOMContentLoaded', () => {
    const stravaEl = document.getElementById("strava-list");
    const userId = stravaEl.dataset.userid;
    ReactDOM.render(
      <StravaList userId={userId} />,
      stravaEl,
    )
  })
  