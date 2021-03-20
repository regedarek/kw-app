export const ADD_TO_CART = 'ADD_TO_CART';
export const REMOVE_FROM_CART = 'REMOVE_FROM_CART';

export const addToCart = (itemId, itemKindId, quantity, item ) => ({
    type: ADD_TO_CART,
    payload: {
        itemId,
        itemKindId,
        quantity,
        item
    }
})
export const removeFromCart = (id) => ({
    type: REMOVE_FROM_CART,
    payload: {
        id
    }
})