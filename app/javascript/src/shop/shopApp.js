import React from 'react';
import {
    HashRouter,
    Switch,
    Route
  } from "react-router-dom";

  import ItemsList from "./itemsList"
  import ItemEdit from "./itemEdit";
import ShopContext from "./shopContext";

function ShopApp({userId}) {
    return <ShopContext.Provider value={userId}>
          <HashRouter>
            <Switch>
              <Route exact path="/">
                <ItemsList />
              </Route>
              <Route path="/new">
                <ItemEdit />
              </Route>
              <Route path="/:id">
                <ItemEdit />
              </Route>
            </Switch>
        </HashRouter>
      </ShopContext.Provider>
}

export default ShopApp;