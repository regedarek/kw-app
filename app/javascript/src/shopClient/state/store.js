import { createStore } from 'redux'
import {ADD_TO_CART, REMOVE_FROM_CART} from "./actions"

const defaultState = {items: []}

function cartReducer(state = defaultState, action) {
    switch (action.type) {
        case ADD_TO_CART:
            return {
                ...state,
                items: [
                    ...state.items,
                    action.payload
                ]
            };
        case REMOVE_FROM_CART:
            return {
                ...state,
                items: [...state.items.slice(0, action.payload.id), ...state.items.slice(action.payload.id+1)]
            }
        default:
            return state
    }
}

export default createStore(cartReducer);