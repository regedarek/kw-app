import React from 'react';

const ReducerContext = React.createContext();

export function userReducerContext() {
  return React.useContext(ReducerContext);
}

export default ReducerContext;