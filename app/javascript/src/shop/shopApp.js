import React from 'react';
import {
    HashRouter,
    Switch,
    Route
  } from "react-router-dom";

  import ItemsList from "./itemsList"
  import ItemEdit from "./itemEdit";

function ShopApp() {
    return <HashRouter>
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
}

export default ShopApp;