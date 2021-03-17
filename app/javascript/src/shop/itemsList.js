import React from 'react';
import Spinner from "../spinner";
import 'whatwg-fetch';
import {
    Link
  } from "react-router-dom";

function ShopList({items}) {
    console.log(items);
    return  <table className="hover">
                <thead>
                    <tr>
                        <th>Nazwa</th>
                        <th width="10%">Status</th>
                        <th>Ostatnia modyfikacja</th>
                        <th>Opis</th>
                        <th width="10%"></th>
                        <th width="10%"></th>
                    </tr>
                </thead>
                <tbody>
                    {items.map(item => 
                        <tr key={item.id} style={{"verticalAlign": "center"}}>
                            <td>
                                {item.name}
                            </td>
                            <td>
                                {item.state}
                            </td>
                            <td>
                                {new Date(item.updated_at).toLocaleDateString()}
                            </td>
                            <td>
                                {item.description}
                            </td>
                            <td className="text-center">
                                <Link to={`/${item.id}`} className="button">
                                    Edytuj
                                </Link>
                            </td>
                            <td className="text-center">
                                <div className="button alert">
                                    Usuń
                                </div>
                            </td>
                        </tr>
                    )}    
                </tbody>
            </table>
}

class ShopListContainer extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoading: true,
            items: []
        }
    }

    componentDidMount() {
        this.loadItems();
    }

    loadItems() {
        window.fetch('/api/items')
        .then(response => response.json())
        .then(data => {
            this.setState({
                items: data,
                isLoading: false
            });
        });
    }

    render() {
        return  <>
                    <div className="row">
                        <div className="columns large-12 text-right">
                            <Link to={`/new`} className="button success">
                                Dodaj nowy przedmiot
                            </Link>
                        </div>
                    </div>
                    <div className="row">
                        <div className="columns large-12">
                            {this.state.isLoading ? <Spinner></Spinner> : <ShopList items={this.state.items}></ShopList>}
                        </div>
                    </div>
                </>
    }
}

export default ShopListContainer;