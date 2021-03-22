import React from 'react';
import ReactDOM from 'react-dom';
import ShopApp from "../src/shopAdmin";

document.addEventListener('DOMContentLoaded', () => {
    const shopEl = document.getElementById("shop");
    ReactDOM.render(
      <ShopApp userId={shopEl.dataset.user_id} />,
      shopEl,
    )
  })