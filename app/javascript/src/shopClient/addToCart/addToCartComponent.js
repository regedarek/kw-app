import React, { useState, useEffect } from 'react';
import { connect } from "react-redux";
import { addToCart } from "../state/actions";

function AddToCartComponent({ addToCart, itemId, itemKinds, userId }) {
    const [selectedKind, setKind] = useState(null);
    const [quantity, setQuantity] = useState(1);

    useEffect(() => {
        if (itemKinds && itemKinds.length === 1) {
            setKind(itemKinds[0])
        }
    })

    const setItemKindObject = (id) => {
        setKind(itemKinds.find(el => `${el.id}` === `${id}`))
    }
    const setValidatedQuantity = (value) => {
        if (value < 1) {
            value = 1;
        }
        if (selectedKind && value > selectedKind.quantity) {
            value = selectedKind.quantity;
        }
        setQuantity(value)
    }

    const addToBasket = () => {
        addToCart(itemId, selectedKind.id, quantity, selectedKind)

        alert('Dodano do koszyka')
    }

    return (
        <div className="row">
            <div className="columns large-10">
                <label htmlFor="kind">Typ</label>
                <select id="kind" name="kind" onChange={(e) => setItemKindObject(e.target.value)}
                    value={selectedKind && selectedKind.id || ""}>
                    <option key={"empty"}>Wybierz rodzaj</option>
                    {itemKinds.map(el => (
                        <option value={el.id} key={el.id}>{el.name} - {el.price} zł</option>
                    ))}
                </select>
            </div>
            <div className="columns large-2">
                <label htmlFor="quantity">Ilość</label>
                <input type="number" id="quantity" name="quantity" disabled={selectedKind === null} 
                    onChange={(e) => setValidatedQuantity(e.target.value)} value={quantity} />
            </div>
            <div className="columns large-12">
                <button className="button success expanded" onClick={() => addToBasket()}>
                    Dodaj do koszyka
                </button>
            </div>
        </div>
    )
}

export default connect(
    null,
    { addToCart }
  )(AddToCartComponent);
