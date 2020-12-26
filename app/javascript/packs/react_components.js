import React from 'react';
import ReactDOM from 'react-dom';
import Hello from "./hello_react";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <Hello name="React" />,
      document.getElementById("test"),
    )
  })
  