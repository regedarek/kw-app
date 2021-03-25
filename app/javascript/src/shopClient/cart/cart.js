import React from 'react';
import {removeFromCart} from "../state/actions";
import { connect } from "react-redux";
import 'whatwg-fetch';

function Cart({items, userId, removeFromCart}) {
    const goToCheckout = () => {
        window.fetch('/api/orders', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                order: {
                    user_id: userId,
                    order_items_attributes: items.map(itemData => ({
                        item_id: itemData.itemId,
                        user_id: userId,
                        item_kind_id: itemData.itemKindId,
                        quantity: itemData.quantity
                    }))
                }
            })          
        })
        .then(response => response.json())
        .then(data => {
            window.location.href = `/zamowienia/${data.id}`
        })
    }

    return (
        <>
            <button type="button" style={{"padding": "0 10px", "cursor": "pointer"}} data-toggle="shopping-cart-dropdown">
                <i className="fi fi-shopping-cart"></i>
                &nbsp;
                <span className="button-icon-badge-text">Koszyk</span>
                &nbsp;
                <span className="badge">{items.length}</span>
            </button>
            <div className="shopping-cart-dropdown-pane">
                <div className="dropdown-pane bottom" id="shopping-cart-dropdown" data-dropdown data-hover="true" data-hover-pane="true">
                    {items.length === 0 && (
                        <div className="columns large-12">
                            Koszyk jest pusty
                        </div>
                    )}
                    {items.length > 0 && (
                        <>
                            {items.map((el, idx) => (
                                    <div className="shopping-cart-item" key={el.id} style={{display: "flex", alignItems: "center"}}>
                                            <div className="columns large-6">
                                                {el.item.name}
                                            </div>
                                            <div className="columns large-3">
                                                {el.quantity}
                                            </div>
                                            <div className="columns large-3 text-center">
                                                <button className="button alert" onClick={() => {removeFromCart(idx)}}>
                                                    <i className="fi fi-x"></i>
                                                </button>
                                            </div>
                                    </div>
                                ))
                            }
                            <button className="button success expanded" onClick={() => goToCheckout()}>Przejdź do płatności</button>
                        </>
                    )}
                </div>
            </div>
        </>
    )
}

const mapStateToProps = state => {
    const { items } = state;
    return { items };
}
export default connect(mapStateToProps, { removeFromCart })(Cart);