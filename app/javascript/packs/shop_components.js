import React from 'react';
import ReactDOM from 'react-dom';
import ShopApp from "../src/shop";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <ShopApp />,
      document.getElementById("shop"),
    )
  })