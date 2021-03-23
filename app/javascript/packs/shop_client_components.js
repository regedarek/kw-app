import React from 'react';
import ReactDOM from 'react-dom';
import AddToCart from "../src/shopClient/addToCart";
import Cart from "../src/shopClient/cart";
import { Provider } from "react-redux";
import store from "../src/shopClient/state/store";

document.addEventListener('DOMContentLoaded', () => {
    const addToCartEl = document.getElementById("add-to-cart");
    if (addToCartEl !== null) {
      const itemId = addToCartEl.dataset.itemid;
      const userId = addToCartEl.dataset.userid;
      const itemKinds = JSON.parse(addToCartEl.dataset.itemkinds);
      
      ReactDOM.render(
        <Provider store={store}>
          <AddToCart itemId={itemId} itemKinds={itemKinds} userId={userId} />
        </Provider>,
        addToCartEl,
      )
    }
    
    const cartEl = document.getElementById("cart");
    if (cartEl !== null) {
      const userId = cartEl.dataset.userid;
      ReactDOM.render(
        <Provider store={store}>
          <Cart userId={userId} />
        </Provider>,
        cartEl,
      )
    }
  })